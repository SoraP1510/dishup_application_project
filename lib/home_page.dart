import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850], // Dark background
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.account_circle, size: 28),
                    Text(
                      'DishUp',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Icon(Icons.notifications, size: 24),
                  ],
                ),
                SizedBox(height: 20),

                // Green Card
                Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                // Goal section
                Center(
                  child: Column(
                    children: [
                      Text("Today's Goal", style: TextStyle(fontSize: 16)),
                      SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: 0,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                        minHeight: 3,
                      ),
                      SizedBox(height: 8),
                      Text(
                        '0 / 6000 Kcal',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                // Meals
                Expanded(
                  child: Column(
                    children: [
                      mealCard('Breakfast'),
                      mealCard('Lunch'),
                      mealCard('Dinner'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),


      // Bottom Navigation Bar
      bottomNavigationBar: BottomAppBar(
        color: Color.fromARGB(255, 255, 255, 255), // soft purple background
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(icon: Icon(Icons.home), onPressed: () {}),
              IconButton(icon: Icon(Icons.calendar_month), onPressed: () {}),
              
               Container(
          height: 120,
          width: 55,
          decoration: BoxDecoration(
            color: Color(0xFF60BC2B),
            borderRadius: BorderRadius.circular(15),
          ),
          child: IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            iconSize: 35,
            onPressed: () {},
          ),
        ),

              IconButton(icon: Icon(Icons.monitor_heart), onPressed: () {}),
              IconButton(icon: Icon(Icons.settings), onPressed: () {}),
            ],
          ),
        ),
      ),
    );
  }

  // Meal Card Widget
  Widget mealCard(String title) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(18),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        title,
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}
