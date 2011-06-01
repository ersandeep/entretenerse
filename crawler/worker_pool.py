import Queue
import threading


class Pool(object):

    def __init__(self, nworkers, handler, timeout=1, extra_kargs=None, initial_item=None):
        self.handler = handler
        self.timeout = timeout
        self.queue = Queue.Queue()
        self.mutex = threading.Lock()
        self.control = {}
        self.workers = [Worker(self, handler, timeout, extra_kargs=extra_kargs) for n in range(nworkers)]
        self.dead_worker_count = 0
        
        if initial_item:
            self.add_to_queue(initial_item)

    def add_to_queue(self, item):
        self.queue.put(item)
        with self.mutex:
            for w in self.workers:
                self.control[w.name] = not w.is_alive()
        
    def start(self):
        for worker in self.workers:
            worker.start()
        
        for worker in self.workers:
            worker.join()

class Worker(threading.Thread):
    
    def __init__(self, pool, handler, timeout=1, extra_kargs=None, *args, **kargs):
        super(Worker, self).__init__(*args, **kargs)
        self.pool = pool
        self.handler = handler
        self.timeout = timeout
        self.extra_kargs = extra_kargs or {}
        
    
    def add_to_queue(self, item):
        self.pool.add_to_queue(item)
        print '%s: Adding %s to queue. Resetting all workers.' % (self.name, str(item))
    
    def queue_is_empty(self):
        with self.pool.mutex:
            self.pool.control[self.name] = 1
        print '%s: Queue was empty.' % self.name
        
    def is_finished(self):
        with self.pool.mutex:
            print '%s: %s idle workers, %s dead workers.' % (self.name, sum(self.pool.control.values()) - self.pool.dead_worker_count, self.pool.dead_worker_count)
            if len(self.pool.workers) == sum(self.pool.control.values()):
                print '%s: Finished processing all items. Now ending.' % self.name
                return True
            else:
                return False
        
    def run(self):
        while True:
            try:
                item = self.pool.queue.get(timeout=self.timeout)
            except Queue.Empty:
                if self.is_finished():
                    break
                self.queue_is_empty()
                continue
            try:
                self.handler(self, item, **self.extra_kargs)
            except:
                print '%s: Caught exception.' % self.name
                self.queue_is_empty()
                self.pool.dead_worker_count += 1
                print '*' * 30, 'offending item was:', item
                raise
