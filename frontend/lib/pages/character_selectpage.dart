import 'package:flutter/material.dart';
import 'global.dart' as global;

class CharacterSelectPage extends StatefulWidget {
  const CharacterSelectPage({super.key});

  @override
  State<CharacterSelectPage> createState() => _CharacterSelectPageState();
}

class _CharacterSelectPageState extends State<CharacterSelectPage> {
  int? selected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          //head of the page
          'My Virtual Character',
          style: TextStyle(
            fontSize: 24,
            color: Color.fromARGB(255, 54, 118, 227),
            fontWeight: FontWeight.bold,
            fontFamily: 'PlayfairDisplay',
          ),
        ),
        backgroundColor: Colors.amber,
      ),

      //selecting part
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Select Your Character',
              style: TextStyle(
                fontSize: 20,
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.bold,
                fontFamily: 'PlayfairDisplay',
                color: Color.fromARGB(255, 5, 45, 113),
              ),
            ),
          ),

          SizedBox(
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 105,
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final character =
                    'assets/virtual_characters/peep-${index + 1}.png';
                final isSelected = selected == index;
                return GestureDetector(
                  onTap: () {
                    global.characterindex = index;
                    Navigator.pop(context, character);

                    setState(() {
                      selected = index;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 8.0),
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.transparent,
                        width: 2,
                      ),
                      image: DecorationImage(
                        image: AssetImage(character),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton(
              onPressed: () {
                if (selected != null) {
                  Navigator.pushNamed(context, '/home', arguments: selected);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a character')),
                  );
                }
              },
              child: Text(
                'Confirm Selection',
                style: TextStyle(fontSize: 18, fontFamily: 'PlayfairDisplay'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
