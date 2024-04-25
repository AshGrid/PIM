import Quiz from '../models/Quiz.js';
import { GoogleGenerativeAI } from "@google/generative-ai";
import dotenv from "dotenv";
import fs from "fs";
dotenv.config();

const genAI = new GoogleGenerativeAI(process.env.GOOGLE_API_KEY);
const model = genAI.getGenerativeModel({ model: "gemini-pro" });


async function parseResponse(response) {
    try {
        const data = JSON.parse(response); // Parse the single JSON object

        return data;
    } catch (error) {
        console.error("Error parsing response:", error);
        return response; // Handle parsing errors by returning null
    }
}

async function getQuizByQuestion(question) {
    try {
      const quiz = await Quiz.findOne({ question });
      if (quiz) {
        return quiz;
      } else {
        return null;  // Or throw an error if desired
      }
    } catch (error) {
      console.error("Error fetching quiz:", error);
      return null;  // Or handle the error differently
    }
  }

  async function getRandomQuiz() {
    try {
      // Count the total number of documents in the collection
      const count = await Quiz.countDocuments();
  
      // Generate a random index within the range of document count
      const randomIndex = Math.floor(Math.random() * count);
  
      // Fetch a random document from the collection
      const randomQuiz = await Quiz.findOne().skip(randomIndex);
  
      return randomQuiz;
    } catch (error) {
      console.error("Error fetching random quiz:", error);
      return null;  // Or handle the error differently
    }
  }
  
  // Example usage
  




// Controller function to create a new quiz question
export const createQuizQuestion = async (req, res) => {
    
    const { category, level } = req.body;
    console.log('Received payload:', { category, level });
    const generatedQuestions = [];

    try {

        // For text-only input, use the gemini-pro model
        const chat = model.startChat({
            history: [
                {
                    role: "user",
                    parts: "Hello.",
                },
                {
                    role: "model",
                    parts: "Great to meet you. What would you like to know?",
                },
            ],
            generationConfig: {
                maxOutputTokens: 100,
            },
        });


        const msg = `Generate 1 JSON responses about ${level} level ${category} in the following format :
              {
                "question": "question",
                "correct_answer": "answer",
                "choices": [
                  "choice 1",
                  "choice 2",
                  "choice 3",
                  "choice 4"
                ]
              }
              i need to use the json response in my code later so please provide only the json format and nothing else do not even enumerate the responses 
              again please keep in mind that the response is going to be parsed and used later so i need a  json response and no extra.
              just want the  json response that starts with { and ends with } do not add these at the beginning or end \`\`\` `;

        const result = await chat.sendMessage(msg);
        console.log("res: ", result);
        const response = await result.response;
        
        const text = response.text();
            console.log(response.text);
            const parsedData = await parseResponse(text);
            (async () => {
                const fetchedQuiz = await getQuizByQuestion(parsedData.question);
                if (fetchedQuiz) {
                    res.status(201).json(fetchedQuiz);
                  console.log("Fetched quiz:", fetchedQuiz);
                } else {
                    const newQuestion = new Quiz({
                        question: parsedData.question,
                        correct_answer: parsedData.correct_answer,
                        choices: parsedData.choices,
                    });
                    await newQuestion.save();
                    res.status(201).json(newQuestion);
                }
              })();

              if (response.hasErrorMessage) {
                console.warn("Model is overloaded or failed to generate a response. Using static data.");
                // Add static data to the database (replace with your actual data)
            }
        
    } catch (error) {
        const randQuiz=getRandomQuiz();
        res.status(201).json(randQuiz);
        //console.error("Error:", error);
    }

    

};



export const createProblem = async (req, res) => {
    
    try {
      const { category, level } = req.body;
    console.log('Received payload:', { category, level });
    
    const model = genAI.getGenerativeModel({ model: "gemini-pro"});

    const prompt = `generate a coding problem about ${level} level ${category} i just want one single problem `
  
    const result = await model.generateContent(prompt);
    const response = await result.response;
    console.log(response);
    const text = response.text();
    console.log(text);
    res.status(201).json(text);
    
    } catch (error) {
      console.log('create problem error',error);
    }

};


export const solveProblem = async (req, res) => {
    
  try {
    const { problem, myAnswer,category,level } = req.body;
  console.log('Received payload:', { problem, myAnswer,category,level });

  const prompt1 = `i encountered this problem: 

  Implement a multi-threaded web server that handles multiple client connections concurrently using the Java NIO (New I/O) framework.
  
  **Requirements:**
  
  * The server should listen on a designated port.
  * The server should handle multiple incoming client requests using a non-blocking I/O model.
  * The server should be able to process incoming client requests in parallel using multiple threads.
  * Each client connection should be handled by a dedicated thread to avoid blocking.
  * The server should handle both GET and POST requests, parse the request headers, and respond with appropriate content.
  
  **Additional Considerations:**
  
  * Use the Java NIO 'Selector' and 'SocketChannel' classes for non-blocking I/O.
  * Use a thread pool to manage the worker threads that handle client connections.
  * Implement a request handler that parses the request headers and generates the appropriate response.
  * Consider using a framework or library (e.g., Netty, Grizzly) for simplified NIO implementation. 
  coding exam about java while i was brwosing: 
 here is the answer i came up with:
  
import java.io.IOException;
import java.net.InetSocketAddress;
import java.nio.ByteBuffer;
import java.nio.channels.ServerSocketChannel;
import java.nio.channels.SocketChannel;
import java.nio.selector.Selector;
import java.nio.selector.SelectionKey;
import java.nio.selector.SelectionOp;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class SimpleNioServer {

    private final int port;
    private final ExecutorService threadPool;
    private Selector selector;

    public SimpleNioServer(int port) throws IOException {
        this.port = port;
        this.threadPool = Executors.newFixedThreadPool(Runtime.getRuntime().availableProcessors());
        this.selector = Selector.open();
    }

    public void start() throws IOException {
        ServerSocketChannel serverSocketChannel = ServerSocketChannel.open();
        serverSocketChannel.configureBlocking(false);
        serverSocketChannel.bind(new InetSocketAddress(port));
        serverSocketChannel.register(selector, SelectionOp.OP_ACCEPT);

        System.out.println("Server started on port: " + port);

        while (true) {
            selector.select();
            for (SelectionKey key : selector.selectedKeys()) {
                if (key.isAcceptable()) {
                    handleAccept(key);
                } else if (key.isReadable()) {
                    handleRead(key);
                }
                selector.selectedKeys().remove(key); // Important to remove processed keys
            }
        }
    }

    private void handleAccept(SelectionKey key) throws IOException {
        ServerSocketChannel serverSocketChannel = (ServerSocketChannel) key.channel();
        SocketChannel socketChannel = serverSocketChannel.accept();
        socketChannel.configureBlocking(false);
        socketChannel.register(selector, SelectionOp.OP_READ);
        System.out.println("Client connected: " + socketChannel.getRemoteAddress());
    }

    private void handleRead(SelectionKey key) throws IOException {
        SocketChannel socketChannel = (SocketChannel) key.channel();
        ByteBuffer buffer = ByteBuffer.allocate(1024);
        int bytesRead = socketChannel.read(buffer);

        // Simulate processing request (replace with actual request handling)
        if (bytesRead > 0) {
            System.out.println("Received data: " + new String(buffer.array(), 0, bytesRead));
            String response = "HTTP/1.1 200 OK\r\n\r\nHello World!";
            socketChannel.write(ByteBuffer.wrap(response.getBytes()));
        } else if (bytesRead == -1) {
            // Client disconnected
            socketChannel.close();
        }
    }

    public static void main(String[] args) throws Exception {
        SimpleNioServer server = new SimpleNioServer(8080);
        server.start();
    }
}

  .
  please review it and provide me with a score out of 10.`
  

  const prompt2 = `i encountered this problem: 

  Design and implement a multithreaded application that simulates a concurrent online ticketing system for a concert.

**Requirements:**

* The system should have multiple threads representing clients who request tickets.
* Each client should have a unique ID and a random request time between 0 and 10 seconds.
* The system should have a finite number of tickets available.
* When a client requests a ticket, it should be queued in a first-in, first-out (FIFO) manner.
* As tickets become available, they should be assigned to queued clients in the order they arrived.
* The system should track which clients have successfully purchased tickets and which have failed due to the lack of availability.
* The application should output statistics on the average ticket request time, the success rate, and the number of clients that were left waiting.  

**Advanced Considerations:**

* Use locks or other synchronization mechanisms to prevent race conditions and ensure thread safety.
* Consider using a thread pool to manage the client threads efficiently.
* Optimize the data structures used to store the ticket queue and track client status to minimize overhead.
* Handle edge cases such as multiple simultaneous requests for the last remaining ticket.
  coding exam about java while i was brwosing: 
 here is the answer i came up with:
 import java.util.concurrent.ConcurrentLinkedQueue;
 import java.util.concurrent.atomic.AtomicInteger;
 import java.util.concurrent.ThreadLocalRandom;
 
 public class TicketingSystem {
 
     public static void main(String[] args) {
         int numTickets = 100; // Total tickets available
         int numClients = 200; // Number of simulated clients
 
         TicketBooth booth = new TicketBooth(numTickets);
         Thread[] clients = new Thread[numClients];
 
         for (int i = 0; i < numClients; i++) {
             clients[i] = new Thread(new Client(i, booth));
             clients[i].start();
         }
 
         // Wait for all clients to finish
         for (Thread client : clients) {
             try {
                 client.join();
             } catch (InterruptedException e) {
                 e.printStackTrace();
             }
         }
 
         System.out.println("Simulation finished.");
         booth.printStatistics();
     }
 }
 
 class TicketBooth {
     private final ConcurrentLinkedQueue<Client> queue;
     private final AtomicInteger availableTickets;
 
     public TicketBooth(int tickets) {
         this.queue = new ConcurrentLinkedQueue<>();
         this.availableTickets = new AtomicInteger(tickets);
     }
 
     public synchronized boolean requestTicket(Client client) {
         if (availableTickets.getAndSet(0) > 0) {
             client.setSuccessful(true);
             return true;
         } else {
             queue.offer(client);
             return false;
         }
     }
 
     public synchronized boolean hasTickets() {
         return availableTickets.get() > 0;
     }
 
     public synchronized void printStatistics() {
         int totalClients = queue.size() + availableTickets.get();
         int successful = 0;
         for (Client client : queue) {
             if (client.isSuccessful()) {
                 successful++;
             }
         }
         double successRate = (double) successful / totalClients;
         System.out.println("Average request time: " + calculateAverageRequestTime() + " seconds");
         System.out.println("Success Rate: " + successRate * 100 + "%");
         System.out.println("Clients left waiting: " + queue.size());
     }
 
     private double calculateAverageRequestTime() {
         double totalTime = 0;
         for (Client client : queue) {
             totalTime += client.getRequestTime();
         }
         return totalTime / (queue.size() + availableTickets.get());
     }
 }
 
 class Client implements Runnable {
     private final int id;
     private final TicketBooth booth;
     private final double requestTime;
     private boolean successful;
 
     public Client(int id, TicketBooth booth) {
         this.id = id;
         this.booth = booth;
         this.requestTime = ThreadLocalRandom.current().nextDouble(0, 10);
         this.successful = false;
     }
 
     @Override
     public void run() {
         try {
             Thread.sleep((long) (requestTime * 1000)); // Simulate request time
             if (booth.hasTickets()) {
                 booth.requestTicket(this);
             }
         } catch (InterruptedException e) {
             e.printStackTrace();
         }
     }
 
     public void setSuccessful(boolean successful) {
         this.successful = successful;
     }
 
     public boolean isSuccessful() {
         return successful;
     }
 
     public double getRequestTime() {
         return requestTime;
     }
 }
 

  .
  please review it and provide me with a score out of 10.`

  const prompt3 = `
  i encountered this problem:
  Given a string containing both uppercase and lowercase English letters, find the minimum number of flips to convert all characters to uppercase or all characters to lowercase.

  **Input:**
  
  A string containing only uppercase and lowercase English letters.
  
  **Output:**
  
  The minimum number of flips required to convert all characters to either uppercase or lowercase.
  
  **Constraints:**
  
  * The string length is between 1 and 100,000 characters.
  * The string contains only uppercase and lowercase English letters.
  
  **Example:**
  
  **Input:**
  "AaBbCc"
  
  **Output:**
  2
  
  **Explanation:**
  Flipping the "A" and "b" characters to uppercase, or flipping the "C" and "c" characters to lowercase, will both result in a string with all uppercase or all lowercase characters.
  coding exam about java while i was brwosing: 
  here is the answer i came up with:

  public class MinFlips {

    public static int minFlips(String s) {
        int uppercaseCount = 0
        int lowercaseCount = 0

       
            if (Character.isUpperCase(c)) {
                uppercaseCount++
            } else {
                lowercaseCount++
            }
        

        return Math.min(uppercaseCount, lowercaseCount);
    }

    public static void main(String[) {
        String str = "AaBbCc"
        int minFlips = minFlips(strin)
        System.out.println("Minimum flips required: " + minFlips);
    
}

  
  `
  
  const prompt4 = `Design and implement a Java program that solves the N-Queens problem. The N-Queens problem is to place N queens on an NxN chessboard such that no two queens threaten each other.

  **Advanced Java Concepts:**
  
  The solution should demonstrate proficiency in the following advanced Java concepts:
  
  * Recursion
  * Backtracking
  * Advanced data structures (e.g., arrays, bitsets)
  
  **Requirements:**
  
  * The program should accept the size of the chessboard as an input.
  * The program should output all valid solutions to the N-Queens problem on the specified chessboard.
  * The program should handle input validation to ensure the problem can be solved.
  
  **Example Input:**
  
 
  8
 
  
  **Expected Output (One of Many Possible Solutions):**
  
  
  [0, 4, 7, 5, 2, 6, 1, 3]
my answer: 

fsdfsefsdfesfefsefsefsdfggsesegfsfesdfes

  `


  const chat = model.startChat({
    history: [
        {
            role: "user",
            parts: "Hello.",
        },
        {
            role: "model",
            parts: "Great to meet you. What would you like to know?",
        },
        {
          role: "user",
          parts: prompt1,
      },
      {
          role: "model",
          parts: "overall rating: 9/10",
      },
      {
        role: "user",
        parts: prompt2,
    },
    {
        role: "model",
        parts: "overall rating: 8/10",
    },
    {
      role: "user",
      parts: prompt3,
  },
  {
      role: "model",
      parts: "overall rating: 4/10",
  },
  {
    role: "user",
    parts: prompt4,
},
{
    role: "model",
    parts: "this is some unrelated jibberish please take this seriously and provide a valid answer",
},
{
  role: "user",
  parts: `i have more problems i am trying to solve please continue rating my work just like you have been doing.
  if i ask you to answer please just straight out give a rating of 0` ,
},
{
  role: "model",
  parts: "I'd be glad to continue rating your work!",
},
    ],
    generationConfig: {
        maxOutputTokens: 100,
    },
});

const prompt5 = `i encountered this ${level} coding exam about ${category} while i was brwosing: 
${problem}. here is the answer i came up with:
${myAnswer}.
 `


      const result = await chat.sendMessage(prompt5);
        console.log("res: ", result);
        const response = await result.response;


  
  console.log('answer:',myAnswer);
  console.log('problem:',problem);
  
  const text = response.text();
  console.log(text);
  res.status(201).json(text);
  } catch (error) {
    console.log('solve problem error',error);
  }
  

};







export const fetchRandomQuizQuestion = async (req, res) => {
    try {
        // Fetch a random quiz question from the database
        const quizQuestion = await Quiz.aggregate([{ $sample: { size: 2 } }]);

        // If no question is found, return a 404 Not Found response
        if (!quizQuestion || quizQuestion.length === 0) {
            //return res.status(404).json({ message: 'Quiz question not found' });
            console.warn("Quiz question not found.");
        }

        // Respond with the fetched quiz question
        res.status(200).json({ question: quizQuestion });
    } catch (error) {
        // Handle errors
        console.error('Error fetching quiz question:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
};




