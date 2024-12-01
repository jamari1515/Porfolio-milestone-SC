import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

public class CounterApp {

    // Shared counter and lock
    private static int counter = 0;
    private static final Lock lock = new ReentrantLock();

    // Thread 1: Count up to 20
    static class CountUpThread extends Thread {
        public void run() {
            for (int i = 0; i <= 20; i++) {
                try {
                    Thread.sleep(1000);  // Simulate work by sleeping for 1 second
                    lock.lock();  // Acquire lock
                    counter = i;
                    System.out.println("Thread 1: " + counter);
                    if (counter == 20) {
                        synchronized (this) {
                            notify();  // Notify Thread 2 to start
                        }
                    }
                } catch (InterruptedException e) {
                    e.printStackTrace();
                } finally {
                    lock.unlock();  // Release lock
                }
            }
        }
    }

    // Thread 2: Count down from 20 to 0
    static class CountDownThread extends Thread {
        public void run() {
            synchronized (CountUpThread.class) {
                try {
                    // Wait for Thread 1 to reach 20
                    while (counter < 20) {
                        wait();
                    }
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }

                // Start counting down
                for (int i = 20; i >= 0; i--) {
                    try {
                        Thread.sleep(1000);  // Simulate work by sleeping for 1 second
                        lock.lock();  // Acquire lock
                        counter = i;
                        System.out.println("Thread 2: " + counter);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    } finally {
                        lock.unlock();  // Release lock
                    }
                }
            }
        }
    }

    // Main method
    public static void main(String[] args) {
        // Create and start threads
        CountUpThread thread1 = new CountUpThread();
        CountDownThread thread2 = new CountDownThread();

        thread1.start();
        thread2.start();

        // Wait for both threads to finish
        try {
            thread1.join();
            thread2.join();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }
}
