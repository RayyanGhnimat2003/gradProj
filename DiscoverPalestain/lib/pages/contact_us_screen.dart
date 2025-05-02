import 'package:flutter/material.dart';


class ContactUsScreen extends StatelessWidget {
  final List<Map<String, String>> team = [
    {
      'name': 'Rayan Hamayel',
      'email': 'rayanghnimat@gmail.com',
      'phone': '0591234567',
    },
    {
      'name': 'Muna Abufalah',
      'email': 'munaabufalah@gmail.com',
      'phone': '0597654321',
    },
    {
      'name': 'Shiren Abed',
      'email': 'shireenabed@gmail.com',
      'phone': '0591112233',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contact Us"),
        backgroundColor:  Colors.teal,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: team.map((member) {
                  return HoverCard(
                    name: member['name']!,
                    email: member['email']!,
                    phone: member['phone']!,
                    width: constraints.maxWidth / 3.5,
                  );
                }).toList(),
              );
            },
          ),
        ),
      ),
    );
  }
}

class HoverCard extends StatefulWidget {
  final String name;
  final String email;
  final String phone;
  final double width;

  HoverCard({
    required this.name,
    required this.email,
    required this.phone,
    required this.width,
  });

  @override
  _HoverCardState createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        margin: EdgeInsets.symmetric(horizontal: 12),
        transform: Matrix4.translationValues(0, _isHovered ? -10 : 0, 0),
        child: Card(
          elevation: _isHovered ? 12 : 6,
          shadowColor: const Color.fromARGB(255, 199, 221, 199),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            height: 300,
            width: widget.width,
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.green.shade100,
                  child: Icon(Icons.person, size: 35, color: Colors.teal),
                ),
                Text(
                  widget.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color:  Colors.teal,
                  ),
                  textAlign: TextAlign.center,
                ),
            Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Icon(Icons.email, size: 16, color: Colors.grey),
    SizedBox(width: 6),
    Flexible(
      child: Text(
        widget.email,
        style: TextStyle(fontSize: 13),
        overflow: TextOverflow.ellipsis,
      ),
    ),
  ],
),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.phone, size: 16, color: Colors.grey),
                    SizedBox(width: 6),
                    Text(widget.phone, style: TextStyle(fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
