title=Petit Workout Queue
date=2016-03-24
type=post
tags=java, petit workout
status=published
~~~~~~


Snow is clearing out, maple syrup is flowing, and the birds are coming back; spring is finally here! This means I'll soon be back on my bike exploring all the amazing land accessible on two wheels - yay! I can't even count how many how many boring hours I've spent on my stationary bike this winter trying to maintain my stamina, cardio and muscle. Now's the time to kick it up a notch, though, and maximize all these remaining living room workouts in order to be in the best shape possible when I hit the streets.

A great way to maximize workouts is to do interval training, i.e. executing series of exercises at difference intensity levels. I tried doing so using my phone's stopwatch, but sweat and phone don't match too well. Besides, how else was I going to learn Java? So I started building my own little workout application.



### Petit Workout


The way our workouts (yes, now it is -our- workout) are to be structured is quite easy; each *workout* contains a series of *intervals* at specific *intensity*. 


	Workout example #1

	+----+-----------+-----------+
	|    |  Duration | Intensity |
	+----+-----------+-----------+
	|  0 |      6000 | "easy"    |
	|  1 |      1000 | "hard"    |
	|  2 |      3000 | "easy"    |
	+----+-----------+-----------+



If we are to focus on the individual intervals, we get objects like the following:



	public class Interval {

	    private String intensity;
	    private long duration;

	    public Interval(String intensity, long duration) 
	    {
	        this.intensity = intensity;
	        this.duration  = duration;
	    }

	    @Override
	    public String toString() 
	    {
	        return "Interval{" +
                "intensity='" + intensity + '\'' +
                ", duration=" + duration +
                '}';
	    }

	    public String getIntensity() 
	    {
	        return intensity;
	    }

	    public long getDuration() 
	    {
	        return duration;
	    }
	}


As you can see, our `Interval` object is a quite basic data struture with getters to retrieve the `intensity` and `duration` of our `Interval` when needed. For our current iteration of the project, we're also implementing an `@Override` of the `Object` `toString()` method to cleanly format output during tests. Note that in Java, every class has the `Object` class as a superclass, all objects implement the methods of this class, including `toString()`.


Now back to our *series*; one concept to extract from the table provided above is that we are effectively wanting to build a `Collection` of `intervals`. From the Java Api documentation: 

> A collection represents a group of objects, known as its elements.


That's pretty abstract, but also on point; a `Collection` is a `group` of `objects`. Defining an abstract concept allows us to narrow down on specific implementations that may better meet our application needs. In this case, `Queues`, which implement the `Collection` interface, seeem to fit the bill as they order elements in a FIFO (first-in-first-out) manner -- *note that there are some exceptions to this ordering, like `Priority queues`, which we won't discuss as this is outside our project's scope*. 

In this little workout sequencing application, once an interval has terminated its execution, i.e. when its fulfilled its duration time, the application needs to initiate the next interval available in the queue.


### Queue


There are many types of queuing patterns available through the Java API `Collection` interface. One of these concrete implementations is the `LinkedList`, which can be used to store and retrieve elements in a list

> Note that Arrays, in Java, are reserved for primative types like integers, doubles, booleans, etc. and not objects, which include strings.


Here is an example of how we can use a `LikedList` as a `Queue` to generate our workout:


	import java.util.LinkedList;

	public class Queue {
	    private LinkedList<Interval> intervalQueue = new LinkedList<>();

	    public synchronized void put(Interval interval)
	    {
	        System.out.println("Queuing: " + interval);

	        intervalQueue.addLast(interval);
	        notifyAll();
	    }

	    public synchronized Interval take()
	    {
	        while (intervalQueue.size() == 0)
	        {
	            try
	            {
	                wait();
	            }
	            catch (InterruptedException e) {}
	        }
	        return intervalQueue.removeFirst();
	    }
	}


Three important concepts to extract from this class are that:

1. Interacting with a `LinkedList` implementation that contains `Interval` objects (`LinkedList<Interval>`) effectively guarantees that we can call the `getDuration` and `getIntensity` methods on the queue's `take` return object.

2. As we are going to implement multiple threads in our application, we need to assure no `concurrency issues` arise. Since the `LinkedList` implementation supplied by the Java Api is not `synchronized`, we may face conflicts if more than one thread attempts to access the list at the same time. The `synchronized` keyword tells the Java Virtual Machine to *lock* an object while it is being accessed by a thread, and to persist this *lock* until the first thread is finished with the object.

3. A thread attempting to extract a value from the queue while the latter is empty will `wait` until an item is added. Also, when the thread attempting to remove an item from the buffer, it notifies other threads to let them know a new element is available for processing.


Now to interact with our queue! We need methods that `put` and `take` items to-and-from the list. There's actually a well know pattern for that: the `Producer-Consumer` pattern. 

From Wikipedia:

> The [Producer-Consumer] problem describes two processes [...] who share a common, fixed-size buffer used as a queue. The producer's job is to generate a piece of data, put it into the buffer and start again. At the same time, the consumer is consuming the data (i.e., removing it from the buffer) one piece at a time. The problem is to make sure that the producer won't try to add data into the buffer if it's full and that the consumer won't try to remove data from an empty buffer.


In other words, a *Producer* is a `thread` that produces new objects intended to be inserted into a queue, and a *Consumer* is the `thread` that processes the queued objects.


### Producer


	public class Producer implements Runnable {

	    protected Queue queue;

	    public Producer(Queue queue) {
	        this.queue = queue;
	    }

	    public void run() {
	        queue.put(new Interval("easy", 6000));
	        queue.put(new Interval("hard", 1000));
	        queue.put(new Interval("easy", 3000));
	    }
	}


### Consumer


	public class Consumer implements Runnable {

	    protected Queue queue;

	    public Consumer(Queue queue) {
	        this.queue = queue;
	    }

	    public void run() {
	        while (true) { consume(queue.take()); }
	    }

	    void consume(Interval x) {
	        System.out.println("Pulling: " + x);
	        try {
	            Thread.sleep(x.getDuration());
	        }
	        catch (InterruptedException e) {}
	    }
	}

** note the dependency injection of the `queue` thread upon the `Producer` and `Consumer` objects. This is how the two classes communicate with each other.


### Testing


	public class QueueTest {

	    public static void main(String[] args) throws Exception {

	        Queue queue = new Queue();

	        Producer producer = new Producer(queue);
	        Consumer consumer = new Consumer(queue);

	        new Thread(producer).start();
	        new Thread(consumer).start();

	    }
	}



As you can see, this is a pretty rudamentary implementation. The `Producer` class places elements unto the queue, which the `Consumer` "takes" out of the queue. The `Consumer` does not take subsequent `Interval` objects until it has terminated a `sleep()` method with a duration 


	Queuing: Interval{intensity='easy', duration=6000}
	Queuing: Interval{intensity='hard', duration=1000}
	Queuing: Interval{intensity='easy', duration=3000}
	Pulling: Interval{intensity='easy', duration=6000}
	Pulling: Interval{intensity='hard', duration=1000}
	Pulling: Interval{intensity='easy', duration=3000}


And that's that! Next up we will try to add a fun GUI :)
