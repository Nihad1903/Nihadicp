Car Management System in Motoko
Description
The Car Management System is a backend system implemented in the Motoko language to efficiently manage car records. This actor-based system supports car creation, retrieval, updates, filtering, soft deletion, and statistical operations. The implementation leverages the Trie data structure for efficient key-value storage and querying.
Features
Core Functionalities:
Create Car Records: Add a new car with key attributes such as make, model, year, price, and a soft-delete flag isActive.

Retrieve Car Details:
Get a car by its unique ID.

Retrieve all cars (active or inactive).
Update Car Records: Modify existing car details by their ID.

Delete Car (Soft Deletion): Mark a car as inactive instead of completely removing it.

Filter Cars:
By price range.
By year range.
By make, country, or title.
Combined filters using optional parameters.
Statistics:

Compute total, average, minimum, and maximum prices of cars.
Count the total number of cars.
Text Search:
Search for cars by their make, country, or title in a case-insensitive manner.

Author:
Nihad Taghiyev
GitHub: https://github.com/Nihad1903
Email: nihadtaghiyev1@gmail.com


Visual
![mascott](https://github.com/user-attachments/assets/958ac971-e2d7-4086-8c41-22df60ab7028)

The bull mascot symbolizes strength, reliability, and efficiency, reflecting the robust and dependable nature of your car management system. Its sleek design represents the modern, tech-driven approach of the project, while the dynamic pose conveys speed and agility in managing car data. The friendly expression emphasizes the user-friendly and accessible nature of the system. Overall, the mascot embodies the power, innovation, and ease of use central to your project.
