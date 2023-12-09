import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Word Search App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Word Search App'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => GridSetupScreen()),
            );
          },
          child: Text('Start Word Search'),
        ),
      ),
    );
  }
}

class GridSetupScreen extends StatefulWidget {
  @override
  _GridSetupScreenState createState() => _GridSetupScreenState();
}

class _GridSetupScreenState extends State<GridSetupScreen> {
  TextEditingController mController = TextEditingController();
  TextEditingController nController = TextEditingController();
  TextEditingController textController = TextEditingController();

  List<List<String>> grid = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Grid Setup'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: mController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Enter number of rows (m)'),
            ),
            TextField(
              controller: nController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Enter number of columns (n)'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                int m = int.tryParse(mController.text) ?? 0;
                int n = int.tryParse(nController.text) ?? 0;
                if (m > 0 && n > 0) {
                  grid = createGrid(m, n);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GridDisplayScreen(
                        grid: grid,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Invalid input. Please enter positive integers.'),
                    ),
                  );
                }
              },
              child: Text('Create Grid'),
            ),
          ],
        ),
      ),
    );
  }

  List<List<String>> createGrid(int m, int n) {
    List<List<String>> newGrid = [];
    Random random = Random();
    for (int i = 0; i < m; i++) {
      List<String> row = [];
      for (int j = 0; j < n; j++) {
        row.add(String.fromCharCode(random.nextInt(26) + 65));
      }
      newGrid.add(row);
    }
    return newGrid;
  }
}

class GridDisplayScreen extends StatefulWidget {
  final List<List<String>> grid;

  GridDisplayScreen({required this.grid});

  @override
  _GridDisplayScreenState createState() => _GridDisplayScreenState();
}

class _GridDisplayScreenState extends State<GridDisplayScreen> {
  TextEditingController textController = TextEditingController();
  late List<bool> highlightedCells;

  @override
  void initState() {
    super.initState();
    highlightedCells = List.filled(widget.grid.length * widget.grid[0].length, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Grid Display'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                highlightedCells = List.filled(widget.grid.length * widget.grid[0].length, false);
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: widget.grid[0].length,
              ),
              itemBuilder: (context, index) {
                int row = index ~/ widget.grid[0].length;
                int col = index % widget.grid[0].length;
                return GestureDetector(
                  onTap: () {
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(),
                      color: highlightedCells[index] ? Colors.yellow : null,
                    ),
                    child: Text(widget.grid[row][col]),
                  ),
                );
              },
              itemCount: widget.grid.length * widget.grid[0].length,
            ),
            SizedBox(height: 20),
            TextField(
              controller: textController,
              decoration: InputDecoration(labelText: 'Enter text to search'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                searchWord(textController.text);
              },
              child: Text('Search Word'),
            ),
          ],
        ),
      ),
    );
  }

  void searchWord(String searchText) {
    List<String> flatGrid = widget.grid.expand((row) => row).toList();
    bool isWordFound = flatGrid.join().contains(searchText);

    if (isWordFound) {
      List<int> wordIndices = [];
      for (int i = 0; i < flatGrid.length; i++) {
        if (flatGrid[i] == searchText[0]) {
          if (isCompleteWordPresent(flatGrid, i, searchText)) {
            for (int j = i; j < i + searchText.length; j++) {
              wordIndices.add(j);
            }
            break;
          }
        }
      }

      setState(() {
        highlightedCells = List.generate(
          widget.grid.length * widget.grid[0].length,
              (index) => wordIndices.contains(index),
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Word found: $searchText'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Word not found: $searchText'),
        ),
      );
    }
  }

  bool isCompleteWordPresent(List<String> flatGrid, int startIndex, String searchText) {
    for (int i = 0; i < searchText.length; i++) {
      int currentIndex = startIndex + i;
      if (currentIndex >= flatGrid.length || flatGrid[currentIndex] != searchText[i]) {
        return false;
      }
    }
    return true;
  }
}
