//
//
// Originally 'TestQueueDriver.swift', taken from https://github.com/vapor/queues
// License: https://github.com/vapor/queues/blob/main/LICENSE

import Queues
import Vapor
import NIOCore
import NIOConcurrencyHelpers

extension Application.Queues.Provider {
    public static var spy: Self {
        .init {
            $0.queues.initializeSpyQueueStorage()
            return $0.queues.use(custom: SpyQueuesDriver())
        }
    }
}

struct SpyQueuesDriver: QueuesDriver {
    let lock: NIOLock

    init() {
        self.lock = .init()
    }

    func makeQueue(with context: QueueContext) -> Queue {
        SpyQueue(lock: self.lock, context: context)
    }
    
    func shutdown() {
        // nothing
    }
}

extension Application.Queues {
    public final class SpyQueueStorage {
        public var jobs: [JobIdentifier: JobData] = [:]
        public var queue: [JobIdentifier] = []

        /// Returns all jobs in the queue of the specific `J` type.
        public func all<J>(_ job: J.Type) -> [J.Payload]
            where J: Job
        {
            let filteredJobIds = jobs.filter { $1.jobName == J.name }.map { $0.0 }

            return queue
                .filter { filteredJobIds.contains($0) }
                .compactMap { jobs[$0] }
                .compactMap { try? J.parsePayload($0.payload) }
        }

        /// Returns the first job in the queue of the specific `J` type.
        public func first<J>(_ job: J.Type) -> J.Payload?
            where J: Job
        {
            let filteredJobIds = jobs.filter { $1.jobName == J.name }.map { $0.0 }
            guard
                let queueJob = queue.first(where: { filteredJobIds.contains($0) }),
                let jobData = jobs[queueJob]
                else {
                    return nil
            }
            
            return try? J.parsePayload(jobData.payload)
        }
        
        /// Checks whether a job of type `J` was dispatched to queue
        public func contains<J>(_ job: J.Type) -> Bool
            where J: Job
        {
            return first(job) != nil
        }
    }
    
    struct SpyQueueKey: StorageKey, LockKey {
        typealias Value = SpyQueueStorage
    }
    
    public var spy: SpyQueueStorage {
        self.application.storage[SpyQueueKey.self]!
    }

    func initializeSpyQueueStorage() {
        self.application.storage[SpyQueueKey.self] = .init()
    }
}

struct SpyQueue: Queue {
    let lock: NIOLock
    let context: QueueContext
    
    func get(_ id: JobIdentifier) -> EventLoopFuture<JobData> {
        self.lock.lock()
        defer { self.lock.unlock() }

        return self.context.eventLoop.makeSucceededFuture(
            self.context.application.queues.spy.jobs[id]!
        )
    }
    
    func set(_ id: JobIdentifier, to data: JobData) -> EventLoopFuture<Void> {
        self.lock.lock()
        defer { self.lock.unlock() }

        self.context.application.queues.spy.jobs[id] = data
        return self.context.eventLoop.makeSucceededFuture(())
    }
    
    func clear(_ id: JobIdentifier) -> EventLoopFuture<Void> {
        self.lock.lock()
        defer { self.lock.unlock() }

        self.context.application.queues.spy.jobs[id] = nil
        return self.context.eventLoop.makeSucceededFuture(())
    }
    
    func pop() -> EventLoopFuture<JobIdentifier?> {
        self.lock.lock()
        defer { self.lock.unlock() }

        let last = context.application.queues.spy.queue.popLast()
        return self.context.eventLoop.makeSucceededFuture(last)
    }
    
    func push(_ id: JobIdentifier) -> EventLoopFuture<Void> {
        self.lock.lock()
        defer { self.lock.unlock() }
        
        self.context.application.queues.spy.queue.append(id)
        return self.context.eventLoop.makeSucceededFuture(())
    }
}
