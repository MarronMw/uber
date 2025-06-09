import 'package:flutter/material.dart';

class DestinationSearchPage extends StatelessWidget {
  final List<Map<String, String>> locations = [
    {'title': 'Zasti Clinic', 'subtitle': 'Lusaka, Chongwe, Chinkuli'},
    {'title': 'Waterfalls hotel', 'subtitle': 'Lusaka, Chongwe, Ntandabale'},
    {
      'title': 'Zaf Lusaka Base Clinic',
      'subtitle': 'Lusaka, Chongwe, Chinkuli',
    },
    {
      'title': 'Lusaka Inter-City Bus Terminus',
      'subtitle': 'Lusaka, Central Business District',
    },
  ];

  DestinationSearchPage({
    super.key,
  }); //just calling thed super class no need for const

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[600],
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'To request a ride',
                    style: TextStyle(color: Colors.white70),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Enter your destination ⬇️',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 12),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: const [
                  Icon(Icons.local_taxi, color: Colors.amber),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Where to? · from K22',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Icon(Icons.search),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.white,
                child: ListView.builder(
                  itemCount: locations.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Icon(Icons.location_on_outlined),
                      title: Text(locations[index]['title']!),
                      subtitle: Text(locations[index]['subtitle']!),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/rideSummary',
                        ); // You define this route
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
