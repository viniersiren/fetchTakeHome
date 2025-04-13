# fetchTakeHome

### Summary: Include screen shots or a video of your app highlighting its features

A video showcasing initial loading is in the main directory called "Screen Recording", then you can check the screenshots in the same directory.


### Focus Areas: What specific areas of the project did you prioritize? Why did you choose to focus on these areas?
I prioritized a clean and efficient interface with a tester user in mind. This is meant to be used/viewed by other engineers so I added in-app options for 
switching betweeen valid, malformed and empty links. I also spent a great deal of time building in image caching. I wasn't certain if CoreData was allowed which is what I am normally proficient with and since I usually use built in network caching methods, this was a great opportunity to learn.

### Time Spent: Approximately how long did you spend working on this project? How did you allocate your time?
I spent around 4-4.5 hours on the project. The initial version was up in around 2 hourss, which included full functionality except reducing network calls(I really
need to make a checklist while reading requirements) and then I had to refactor some of the views to fit the new caching method. 

### Trade-offs and Decisions: Did you make any significant trade-offs in your approach?
I don't believe my approach incurred any tradeoffs. I would love the opportunity to discuss possible pitfalls of my code, I think it would really elevate my
code quality. I chose to use a list for better performance without hogging memory since it pops views in and out of memory as you scroll unlike a lazyvsstack 
which only pops them in as you scroll resulting in lag the further down you go.

### Weakest Part of the Project: What do you think is the weakest part of your project?
I am both uncertain about the efficiency of my custom caching method and how to properly test it. A weakness of the project is the lack of style, it is 
pretty minimial and tasteless.

### Additional Information: Is there anything else we should know? Feel free to share any insights or constraints you encountered.
Overall I liked taking away the caching methods that I have previously relied on. It was interesting but I'm unsure that it is an accurate measure of the quality of an iOS developer. 
