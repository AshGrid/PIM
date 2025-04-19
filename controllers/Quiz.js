import Quiz from '../models/Quiz.js';
//import { GoogleGenerativeAI } from "@google/generative-ai";
import { GoogleGenAI } from "@google/genai";
import dotenv from "dotenv";
import fs from "fs";
import mongoose from "mongoose";
dotenv.config();

const ai = new GoogleGenAI({ apiKey: process.env.GOOGLE_API_KEY });



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

async function getRandomQuizz(category, level, excludeIds = []) {
    return Quiz.aggregate([
        {
            $match: {
                category,
                level,
                _id: { $nin: excludeIds }  // Exclude already-seen IDs
            }
        },
        { $sample: { size: 1 } }
    ]);
}


// Controller function to create a new quiz question
export const createQuizQuestion = async (req, res) => {
    const { category, level } = req.body;
    console.log('Received payload:', { category, level });

    // Basic Input Validation
    if (!category || !level) {
        return res.status(400).json({ message: 'Category and level are required parameters.' });
    }

    try {
        // --- Initialize AI Chat ---
        // Note: Ensure 'ai.chats.create' and model name are correct for your library/provider
        const chat = ai.chats.create({ // Assuming ai.chats.create correctly returns a chat session object
            model: "gemini-1.5-flash",
        });

        // --- Construct the Prompt ---
        const msg = `Generate 1 single JSON object representing a multiple-choice quiz question about the topic "${category}" at a "${level}" difficulty level.
        Follow this exact JSON format:
        {
          "question": "The text of the question?",
          "correct_answer": "The single correct answer string",
          "choices": [
            "Choice A",
            "Choice B",
            "Choice C",
            "The correct answer string must also be present here"
          ]
        }
        IMPORTANT: Provide ONLY the JSON object itself, starting with { and ending with }. Do NOT include any introductory text, explanations, code block markers like \`\`\`json, or any other text outside the JSON structure. The response must be directly parsable as JSON. Ensure the "correct_answer" value is included exactly within the "choices" array.`;

        console.log("Sending prompt to AI...");

        // --- Call the AI ---
        // Assuming chat.sendMessage returns the GenerateContentResponse directly
        const result = await chat.sendMessage({ message: msg }); // Removed the { message: msg } wrapper if sendMessage just takes the string
        console.log("Received AI result structure:", result); // Log the structure

        // --- Process AI Response ---

        // **FIXED PART STARTS HERE**

        // 1. Check for top-level blocking/errors first (using result directly)
        // Adjust based on actual library structure if promptFeedback isn't top-level
        if (result.promptFeedback?.blockReason) {
            console.warn(`AI generation blocked. Reason: ${result.promptFeedback.blockReason}.`);
            console.log("Falling back to random quiz due to AI block.");
            const randQuiz = await getRandomQuiz();
            return res.status(200).json(randQuiz || { message: "AI blocked, fallback quiz unavailable." });
        }

        // 2. Check if candidates exist and are valid
        if (!result.candidates || !Array.isArray(result.candidates) || result.candidates.length === 0) {
            throw new Error("AI response is missing 'candidates' array or it's empty.");
        }

        // 3. Access the first candidate
        const candidate = result.candidates[0];

        // 4. Check candidate structure and content
        if (!candidate.content || !candidate.content.parts || !Array.isArray(candidate.content.parts) || candidate.content.parts.length === 0) {
            // Also check finishReason for potential issues other than STOP
            const finishReason = candidate.finishReason || 'UNKNOWN';
            console.warn(`AI candidate has no content parts. Finish reason: ${finishReason}`);
            throw new Error(`AI candidate is missing content parts or finished unexpectedly (${finishReason}).`);
        }

        // 5. Extract the text from the first part
        const text = candidate.content.parts[0].text;
        console.log("AI Raw Response Text:", text);

        if (!text || typeof text !== 'string' || text.trim() === '') {
            throw new Error("AI returned an empty or invalid text response from candidate part.");
        }

        // **FIXED PART ENDS HERE**


        // --- Parse the AI Response ---
        let parsedData;
        try {
            parsedData = await parseResponse(text); // Use your robust parser

            if (!parsedData || typeof parsedData.question !== 'string' || typeof parsedData.correct_answer !== 'string' || !Array.isArray(parsedData.choices) || parsedData.choices.length < 2 || !parsedData.choices.includes(parsedData.correct_answer)) {
                throw new Error("Parsed AI response does not match expected format or content.");
            }
            console.log("Parsed Data:", parsedData);

        } catch (parseError) {
            console.error("Failed to parse AI response:", parseError);
            console.error("Raw text that failed parsing:", text);
            console.log("Falling back to random quiz due to parsing error.");
            const randQuiz = await getRandomQuiz();
            return res.status(200).json(randQuiz || { message: "Parsing failed, fallback quiz unavailable." });
        }


        // --- Check Database and Respond ---
        const fetchedQuiz = await getQuizByQuestion(parsedData.question);

        if (fetchedQuiz) {
            console.log("Question already exists in DB. Returning existing quiz:", fetchedQuiz._id);
            res.status(200).json(fetchedQuiz);
        } else {
            console.log("Question not found in DB. Creating new quiz...");
            const newQuestion = new Quiz({
                question: parsedData.question,
                correct_answer: parsedData.correct_answer,
                choices: parsedData.choices,
                category: category,
                level: level,
            });
            await newQuestion.save();
            console.log("New question saved:", newQuestion._id);
            res.status(200).json(newQuestion);
        }

    } catch (error) {
        console.error("Error in createQuizQuestion controller:", error);
        res.status(500).json({
            message: "An unexpected error occurred while creating the quiz question.",
            error: error.message || 'Unknown error',
        });
    }
};



export const createQuizQuestionn = async (req, res) => {
    console.log("logging fetch question");
    const { category, level, excludeIds = [] } = req.body;
    console.log('Received payload:', { category, level, excludeIds });

    // Basic Input Validation
    if (!category || !level) {
        return res.status(400).json({ message: 'Category and level are required parameters.' });
    }

    try {
        // First try to get a random question from the database
        const randomQuiz = await getRandomQuizByCategory(category, level, excludeIds);

        if (randomQuiz && randomQuiz.length > 0) {
            console.log("Returning existing random quiz from DB");
            return res.status(200).json(randomQuiz[0]);
        }

        console.log("No existing quizzes found, generating new one with AI...");

        // --- AI Question Generation Fallback ---
        const chat = ai.chats.create({
            model: "gemini-1.5-flash",
        });

        const msg = `Generate 1 single JSON object representing a multiple-choice quiz question about the topic "${category}" at a "${level}" difficulty level.
        Follow this exact JSON format:
        {
          "question": "The text of the question?",
          "correct_answer": "The single correct answer string",
          "choices": [
            "Choice A",
            "Choice B",
            "Choice C",
            "The correct answer string must also be present here"
          ]
        }
        IMPORTANT: Provide ONLY the JSON object itself, starting with { and ending with }. Do NOT include any introductory text, explanations, code block markers like \`\`\`json, or any other text outside the JSON structure. The response must be directly parsable as JSON. Ensure the "correct_answer" value is included exactly within the "choices" array.`;


        const result = await chat.sendMessage({ message: msg });

        // Error handling for AI response
        if (result.promptFeedback?.blockReason) {
            throw new Error(`AI generation blocked: ${result.promptFeedback.blockReason}`);
        }

        if (!result.candidates?.[0]?.content?.parts?.[0]?.text) {
            throw new Error("Invalid AI response structure");
        }

        const text = result.candidates[0].content.parts[0].text;
        const parsedData = JSON.parse(text);

        // Validate parsed data
        if (!parsedData.question || !parsedData.correct_answer || !parsedData.choices) {
            throw new Error("AI generated invalid question format");
        }

        // Save the new question
        const newQuestion = new Quiz({
            question: parsedData.question,
            correct_answer: parsedData.correct_answer,
            choices: parsedData.choices,
            category: category,
            level: level,
        });

        await newQuestion.save();
        console.log("New question saved:", newQuestion._id);
        return res.status(200).json(newQuestion);

    } catch (error) {
        console.error("Error in createQuizQuestion:", error);

        // Final fallback - try to get ANY random question
        try {
            const fallbackQuiz = await Quiz.aggregate([{
                $match: {
                    category: category,
                    level: level
                }
            }, { $sample: { size: 1 } }]);

            if (fallbackQuiz.length > 0) {
                return res.status(200).json(fallbackQuiz[0]);
            }
        } catch (fallbackError) {
            console.error("Fallback also failed:", fallbackError);
        }

        return res.status(500).json({
            message: "Failed to generate or retrieve quiz question",
            error: error.message
        });
    }
};

// Helper function to get random quiz with filters
async function getRandomQuizByCategory(category, level, excludeIds = []) {
    return Quiz.aggregate([
        {
            $match: {
                category: category,
                level: level,
                _id: { $nin: excludeIds.map(id => new mongoose.Types.ObjectId(id)) }
            }
        },
        { $sample: { size: 1 } }
    ]);
}



export const createProblem = async (req, res) => {
    const { category, level } = req.body;
    console.log('Received payload for createProblem:', { category, level });

    // Basic Input Validation
    if (!category || !level) {
        return res.status(400).json({ message: 'Category and level are required parameters.' });
    }

    try {
        // 1. Construct the Prompt
        const prompt = `Generate a description for a coding problem suitable for a ${level} level assessment on the topic of ${category}.
        The description should be clear, concise, and present the challenge effectively.
        Provide only the problem description text itself, without any introductory phrases like "Here is a problem:", "Problem:", or "Description:".`;

        console.log("Sending prompt to AI for coding problem generation using ai.models.generateContent...");

        // 2. Call the AI using your specific 'ai' client method
        // Ensure parameters are correct for this specific method
        const result = await ai.models.generateContent({
            model: "gemini-1.5-flash", // Use a valid model name
            contents: prompt, // Assuming 'contents' is the right parameter name
        });

        // 3. Process the AI Response (assuming 'result' IS the GenerateContentResponse object)
        console.log("Received AI result structure:", result);

        // --- Start Parsing the Complex Object ---

        // Optional: Check for safety blocks or other non-STOP finish reasons
        // Accessing feedback directly on the result object IF that's its structure
        // Check your actual 'result' object structure if this differs
        if (result.promptFeedback?.blockReason) {
            console.warn(`AI generation blocked. Reason: ${result.promptFeedback.blockReason}.`);
            return res.status(503).json({ message: `AI generation failed due to content blocking: ${result.promptFeedback.blockReason}` });
        }

        // Extract text correctly from the candidate within the result object
        const candidates = result.candidates; // Access candidates directly from the result

        if (!candidates || !Array.isArray(candidates) || candidates.length === 0) {
            console.error("AI response object is missing 'candidates' array or it's empty. Full response:", JSON.stringify(result, null, 2));
            throw new Error("AI response object is missing 'candidates' array or it's empty.");
        }

        const candidate = candidates[0];

        if (!candidate.content?.parts?.[0]?.text) {
            console.error("Could not find text in AI response candidate part. Full response:", JSON.stringify(result, null, 2));
            const finishReason = candidate.finishReason || 'UNKNOWN';
            throw new Error(`Could not extract text from AI response structure. Finish reason: ${finishReason}`);
        }

        // Get the generated text from the correct path
        const text = candidate.content.parts[0].text;
        // --- End Parsing the Complex Object ---


        // 4. Validate the Extracted Text
        if (typeof text !== 'string' || text.trim() === '') {
            // This error should ideally not be hit if the path above is correct and AI provides text
            console.error("Extracted text is empty or invalid:", text);
            throw new Error("AI returned empty or invalid text content after extraction.");
        }

        const problemDescription = text.trim(); // Clean up whitespace
        console.log("Generated Problem Description:", problemDescription);

        // 5. Send Success Response
        res.status(200).json({ problem: problemDescription });

    } catch (error) {
        console.error('Error in createProblem controller:', error);
        // Log stack trace for detailed debugging
        console.error(error.stack);
        res.status(500).json({
            message: "Failed to generate coding problem.",
            error: error.message || 'Unknown server error',
        });
    }
};


export const solveProblemm = async (req, res) => {
    const { problem, myAnswer,category,level } = req.body;
    if (!category || !level || !problem || !myAnswer) {
        return res.status(400).json({ message: 'Category, level, problem and answer are required parameters.' });
    }
  try {

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



export const solveProblem = async (req, res) => {
    const { problem, myAnswer,category,level } = req.body;
    if (!category || !level || !problem || !myAnswer) {
        return res.status(400).json({ message: 'Category, level, problem and answer are required parameters.' });
    }
    try {
        // --- Initialize AI Chat ---
        // Note: Ensure 'ai.chats.create' and model name are correct for your library/provider

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

        const chat = ai.chats.create({ // Assuming ai.chats.create correctly returns a chat session object
            model: "gemini-1.5-flash",
            history: [
                {
                    role: "user",
                    parts: [{ text: "Hello" }],
                },
                {
                    role: "model",
                    parts: [{text:"Great to meet you. What would you like to know?"}],
                },
                {
                    role: "user",
                    parts: [{text:prompt1}],
                },
                {
                    role: "model",
                    parts: [{text:"overall rating: 9/10"}],
                },
                {
                    role: "user",
                    parts: [{text:prompt2}],
                },
                {
                    role: "model",
                    parts: [{text:"overall rating: 8/10"}],
                },
                {
                    role: "user",
                    parts: [{text:prompt3}],
                },
                {
                    role: "model",
                    parts: [{text:"overall rating: 4/10"}],
                },
                {
                    role: "user",
                    parts: [{text:prompt4}],
                },
                {
                    role: "model",
                    parts: [{text:"this is some unrelated jibberish please take this seriously and provide a valid answer"}],
                },
                {
                    role: "user",
                    parts: [{text:`i have more problems i am trying to solve please continue rating my work just like you have been doing.
  if i ask you to answer please just straight out give a rating of 0`
                }] ,
                },
                {
                    role: "model",
                    parts: [{text:"I'd be glad to continue rating your work!"}],
                },
            ],

        });

        const currentPrompt = `i encountered this ${level} coding exam about ${category} while i was brwosing: 
${problem}. 

here is the answer i came up with:
${myAnswer}.

please review it and provide me with a score out of 10, following the same pattern as before.`; // Be explicit

        console.log("Sending prompt to AI for review...");

        // --- Call the AI with Correct Message Format ---
        const result = await chat.sendMessage({ message: currentPrompt });  // Corrected format

        console.log("Received AI result structure:", result); // Log the structure

        // --- Process AI Response (for review text) ---

        // 1. Check for blocking/errors
        if (result.promptFeedback?.blockReason) {
            console.warn(`AI generation blocked. Reason: ${result.promptFeedback.blockReason}.`);
            // Decide how to handle blocking (e.g., error message)
            return res.status(503).json({ message: `AI generation failed due to content blocking: ${result.promptFeedback.blockReason}` });
        }

        // 2. Check candidates and extract text
        if (!result.candidates?.[0]?.content?.parts?.[0]?.text) {
            console.error("Could not find text in AI response candidates. Full response:", JSON.stringify(result.response || result, null, 2)); // Log full response if available
            const finishReason = result.candidates?.[0]?.finishReason || 'UNKNOWN';
            throw new Error(`Could not extract review text from AI response structure. Finish reason: ${finishReason}`);
        }

        // 3. Get the review text
        const reviewText = result.candidates[0].content.parts[0].text;
        console.log("AI Raw Review Text:", reviewText);

        if (typeof reviewText !== 'string' || reviewText.trim() === '') {
            throw new Error("AI returned an empty or invalid text response for the review.");
        }

        // --- Send the Review Back to the Client ---
        res.status(200).json({ review: reviewText.trim() }); // Send the review text

    } catch (error) {
        // Log the specific error type if available (like ClientError)
        console.error(`Error in solveProblem controller: ${error.name} - ${error.message}`);
        // Log the full error object for details, including potential cause
        console.error(error);
        res.status(500).json({
            message: "An unexpected error occurred while getting the problem review.",
            error: error.message || 'Unknown server error',
        });
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




