#include <iostream>
#include <thread>
#include <mutex>
#include <condition_variable>
#include <chrono>

std::mutex mtx;                 // Mutex to synchronize access to counter
std::condition_variable cv;     // Condition variable to notify thread
int counter = 0;                // Shared counter

// Thread 1 function: Counts up to 20
void countUp() {
    for (int i = 0; i <= 20; ++i) {
        std::this_thread::sleep_for(std::chrono::seconds(1));  // Simulate some work
        std::lock_guard<std::mutex> lock(mtx);  // Lock mutex to access the counter
        counter = i;
        std::cout << "Thread 1: " << counter << std::endl;
        if (counter == 20) {
            cv.notify_one();  // Notify thread 2 to start
        }
    }
}

// Thread 2 function: Counts down from 20
void countDown() {
    std::unique_lock<std::mutex> lock(mtx);
    cv.wait(lock, []{ return counter == 20; });  // Wait until thread 1 reaches 20
    
    for (int i = 20; i >= 0; --i) {
        std::this_thread::sleep_for(std::chrono::seconds(1));  // Simulate some work
        counter = i;
        std::cout << "Thread 2: " << counter << std::endl;
    }
}

int main() {
    // Create two threads to run countUp and countDown
    std::thread t1(countUp);
    std::thread t2(countDown);

    // Wait for both threads to finish
    t1.join();
    t2.join();

    return 0;
}
