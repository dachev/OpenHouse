import Queue
import threading
import urllib2

class ThreadUrl(threading.Thread):
    def __init__(self, queue):
        threading.Thread.__init__(self)
        self.queue = queue
          
    def run(self):
        while True:
            url = self.queue.get()

            try:
                url = urllib2.urlopen(url)
                url.read(1024)
            except:
                f=''
            
            self.queue.task_done()
