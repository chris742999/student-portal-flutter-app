import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'report_screen.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Summit University',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginPage(),
    );
  }
}

// User Model
class Student {
  String id;
  String name;
  String email;
  String course;
  String year;
  String documentId;

  Student({
    required this.id,
    required this.name,
    required this.email,
    required this.course,
    required this.year,
    required this.documentId,
  });
}

// Login Page with Animated Graduation Hat
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  late AnimationController _animationController;
  late Animation<double> _shakeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  Future<void> addStudent() async {
    try {
      print("BUTTON CLICKED");

      await FirebaseFirestore.instance.collection('students').add({
        'name': 'John Doe',
        'course': 'Computer Science',
        'year': '1st Year',
        'studentId': 'TEST001',
        'email': 'john@test.com',
        'createdAt': Timestamp.now(),
      });

      print("DATA SAVED");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Student saved to Firebase"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print("FIREBASE ERROR: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Firebase Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(begin: 0.0, end: 0.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticIn),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    passwordController.addListener(_animateHat);
  }

  void _animateHat() {
    if (passwordController.text.isNotEmpty) {
      _animationController.forward(from: 0.0);
    } else {
      _animationController.reset();
    }
  }

  void login() {
    if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainNavigationPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please fill all fields"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    passwordController.removeListener(_animateHat);
    emailController.dispose();
    passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF232022),
              Color(0xFF432837),
              Color(0xFF682C47),
              Color(0xFF8F2D51),
              Color(0xFFB72C54),
              Color(0xFFBE345F),
              Color(0xFFC53B6B),
              Color(0xFFCC4377),
              Color(0xFFAC5486),
              Color(0xFF8C6088),
              Color(0xFF73657C),
              Color(0xFF666666),
            ],
            stops: [
              0.0, 0.09, 0.18, 0.27, 0.36,
              0.45, 0.54, 0.63, 0.72, 0.81, 0.90, 1.0
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Card(
              elevation: 20,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..rotateZ(_shakeAnimation.value)
                            ..scale(_scaleAnimation.value),
                          child: Transform.rotate(
                            angle: _rotationAnimation.value,
                            child: Icon(
                              Icons.school,
                              size: 80,
                              color: Color(0xFFB72C54),
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Summit University",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFB72C54),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 30),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.email, color: Color(0xFFB72C54)),
                        labelText: "Email",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Color(0xFFB72C54), width: 2),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 15),
                    TextField(
                      controller: passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock, color: Color(0xFFB72C54)),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            color: Color(0xFFB72C54),
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                        labelText: "Password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Color(0xFFB72C54), width: 2),
                        ),
                      ),
                    ),
                    SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFB72C54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "LOGIN",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 15),
                    TextButton(
                      onPressed: () {},
                      child: Text("Forgot Password?", style: TextStyle(color: Color(0xFFB72C54))),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Main Navigation Page with Bottom Navigation
class MainNavigationPage extends StatefulWidget {
  @override
  _MainNavigationPageState createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    DashboardScreen(),
    StudentRegistrationScreen(),
    StudentListScreen(),
    CourseScreen(),
    ProfileScreen(),
  ];

  final List<String> _titles = [
    "Dashboard",
    "Register Student",
    "Students",
    "Courses",
    "Profile",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF232022),
                Color(0xFF432837),
                Color(0xFF682C47),
                Color(0xFF8F2D51),
                Color(0xFFB72C54),
              ],
            ),
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Color(0xFFB72C54),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.person_add), label: "Register"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Students"),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Courses"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

// Dashboard Screen
class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF232022),
            Color(0xFF432837),
            Color(0xFF682C47),
            Color(0xFF8F2D51),
            Color(0xFFB72C54),
            Color(0xFFBE345F),
            Color(0xFFC53B6B),
            Color(0xFFCC4377),
            Color(0xFFAC5486),
            Color(0xFF8C6088),
            Color(0xFF73657C),
            Color(0xFF666666),
          ],
          stops: [
            0.0, 0.09, 0.18, 0.27, 0.36,
            0.45, 0.54, 0.63, 0.72, 0.81, 0.90, 1.0
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome back!",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Manage your students efficiently",
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              SizedBox(height: 30),
              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: MediaQuery.of(context).size.width < 600 ? 2 : 4,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  buildDashboardCard(
                    context,
                    "Register Student",
                    Icons.person_add,
                    Colors.blue,
                        () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => StudentRegistrationScreen()),
                    ),
                  ),
                  buildDashboardCard(
                    context,
                    "View Students",
                    Icons.list,
                    Colors.green,
                        () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => StudentListScreen()),
                    ),
                  ),
                  buildDashboardCard(
                    context,
                    "Courses",
                    Icons.book,
                    Colors.orange,
                        () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CourseScreen()),
                    ),
                  ),
                  buildDashboardCard(
                    context,
                    "Reports",
                    Icons.analytics,
                    Colors.purple,
                        () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ReportScreen()),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              // Quick Stats Card with Firestore Stream
              Card(
                elevation: 4,
                color: Colors.white.withOpacity(0.95),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Quick Stats",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFB72C54)),
                      ),
                      SizedBox(height: 20),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection('students').snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Text("Error loading stats");
                          }

                          int totalStudents = snapshot.hasData ? snapshot.data!.docs.length : 0;

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              buildStatItem("Total Students", totalStudents.toString(), Color(0xFFB72C54)),
                              buildStatItem("Active Courses", "6", Color(0xFFB72C54).withOpacity(0.7)),
                              buildStatItem("Pass Rate", "94%", Color(0xFFB72C54).withOpacity(0.5)),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDashboardCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
        ),
        SizedBox(height: 5),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }
}

// Student Registration Screen
class StudentRegistrationScreen extends StatefulWidget {
  @override
  _StudentRegistrationScreenState createState() => _StudentRegistrationScreenState();
}

class _StudentRegistrationScreenState extends State<StudentRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  String selectedCourse = "Computer Science";
  String selectedYear = "1st Year";

  final List<String> courses = [
    "Computer Science",
    "Engineering",
    "Business",
    "Mathematics",
    "Physics",
    "Chemistry",
  ];

  final List<String> years = [
    "1st Year",
    "2nd Year",
    "3rd Year",
    "4th Year",
  ];

  Future<void> registerStudent() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Save to Firestore
        await FirebaseFirestore.instance.collection('students').add({
          'studentId': idController.text,
          'name': nameController.text,
          'email': emailController.text,
          'course': selectedCourse,
          'year': selectedYear,
          'createdAt': Timestamp.now(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Student registered successfully!"),
            backgroundColor: Colors.green,
          ),
        );

        // Reset form
        _formKey.currentState!.reset();
        nameController.clear();
        emailController.clear();
        idController.clear();

        // Reset dropdowns
        setState(() {
          selectedCourse = "Computer Science";
          selectedYear = "1st Year";
        });

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF232022),
            Color(0xFF432837),
            Color(0xFF682C47),
            Color(0xFF8F2D51),
            Color(0xFFB72C54),
            Color(0xFFBE345F),
            Color(0xFFC53B6B),
            Color(0xFFCC4377),
            Color(0xFFAC5486),
            Color(0xFF8C6088),
            Color(0xFF73657C),
            Color(0xFF666666),
          ],
          stops: [
            0.0, 0.09, 0.18, 0.27, 0.36,
            0.45, 0.54, 0.63, 0.72, 0.81, 0.90, 1.0
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Card(
            elevation: 8,
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Icon(
                        Icons.school,
                        size: 80,
                        color: Color(0xFFB72C54),
                      ),
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: Text(
                        "Student Registration",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFB72C54),
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: "Full Name",
                        prefixIcon: Icon(Icons.person, color: Color(0xFFB72C54)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Color(0xFFB72C54), width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter student name";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: idController,
                      decoration: InputDecoration(
                        labelText: "Student ID",
                        prefixIcon: Icon(Icons.badge, color: Color(0xFFB72C54)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Color(0xFFB72C54), width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter student ID";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: "Email",
                        prefixIcon: Icon(Icons.email, color: Color(0xFFB72C54)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Color(0xFFB72C54), width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter email";
                        }
                        if (!value.contains('@')) {
                          return "Please enter valid email";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField(
                      value: selectedCourse,
                      decoration: InputDecoration(
                        labelText: "Course",
                        prefixIcon: Icon(Icons.book, color: Color(0xFFB72C54)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Color(0xFFB72C54), width: 2),
                        ),
                      ),
                      items: courses.map((course) {
                        return DropdownMenuItem(
                          value: course,
                          child: Text(course),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCourse = value!;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField(
                      value: selectedYear,
                      decoration: InputDecoration(
                        labelText: "Year",
                        prefixIcon: Icon(Icons.calendar_today, color: Color(0xFFB72C54)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Color(0xFFB72C54), width: 2),
                        ),
                      ),
                      items: years.map((year) {
                        return DropdownMenuItem(
                          value: year,
                          child: Text(year),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedYear = value!;
                        });
                      },
                    ),
                    SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: registerStudent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFB72C54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "REGISTER STUDENT",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Student List Screen with Firestore
class StudentListScreen extends StatefulWidget {
  @override
  _StudentListScreenState createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF232022),
            Color(0xFF432837),
            Color(0xFF682C47),
            Color(0xFF8F2D51),
            Color(0xFFB72C54),
            Color(0xFFBE345F),
            Color(0xFFC53B6B),
            Color(0xFFCC4377),
            Color(0xFFAC5486),
            Color(0xFF8C6088),
            Color(0xFF73657C),
            Color(0xFF666666),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("Student List"),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF232022),
                  Color(0xFF432837),
                  Color(0xFF682C47),
                  Color(0xFF8F2D51),
                  Color(0xFFB72C54),
                ],
              ),
            ),
          ),
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                showSearch(context: context, delegate: StudentSearchDelegate());
              },
            ),
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('students')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Error: ${snapshot.error}",
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final students = snapshot.data!.docs;

            if (students.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.people_outline,
                      size: 80,
                      color: Colors.white70,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "No students registered yet",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => StudentRegistrationScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB72C54),
                      ),
                      child: const Text("Register First Student"),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: students.length,
              itemBuilder: (context, index) {
                final studentData = students[index].data() as Map<String, dynamic>;
                final docId = students[index].id;

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundColor: const Color(0xFFB72C54),
                      child: Text(
                        studentData['name'][0].toUpperCase(),
                        style: const TextStyle(fontSize: 24, color: Colors.white),
                      ),
                    ),
                    title: Text(
                      studentData['name'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text("ID: ${studentData['studentId'] ?? ''}"),
                        Text("Email: ${studentData['email'] ?? ''}"),
                        Text("${studentData['course']} - ${studentData['year']}"),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      onPressed: () async {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Delete Student"),
                              content: Text("Are you sure you want to delete ${studentData['name']}?"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Cancel"),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    await FirebaseFirestore.instance
                                        .collection('students')
                                        .doc(docId)
                                        .delete();
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Student deleted")),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  child: const Text("Delete"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// Course Screen
class CourseScreen extends StatelessWidget {
  final List<Map<String, dynamic>> courses = [
    {
      "name": "Computer Science",
      "duration": "4 Years",
      "students": 45,
      "icon": Icons.computer,
      "color": Colors.blue,
    },
    {
      "name": "Engineering",
      "duration": "4 Years",
      "students": 38,
      "icon": Icons.engineering,
      "color": Colors.green,
    },
    {
      "name": "Business",
      "duration": "3 Years",
      "students": 52,
      "icon": Icons.business,
      "color": Colors.orange,
    },
    {
      "name": "Mathematics",
      "duration": "3 Years",
      "students": 28,
      "icon": Icons.calculate,
      "color": Colors.purple,
    },
    {
      "name": "Physics",
      "duration": "3 Years",
      "students": 32,
      "icon": Icons.science,
      "color": Colors.red,
    },
    {
      "name": "Chemistry",
      "duration": "3 Years",
      "students": 30,
      "icon": Icons.science,
      "color": Colors.teal,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF232022),
            Color(0xFF432837),
            Color(0xFF682C47),
            Color(0xFF8F2D51),
            Color(0xFFB72C54),
            Color(0xFFBE345F),
            Color(0xFFC53B6B),
            Color(0xFFCC4377),
            Color(0xFFAC5486),
            Color(0xFF8C6088),
            Color(0xFF73657C),
            Color(0xFF666666),
          ],
          stops: [
            0.0, 0.09, 0.18, 0.27, 0.36,
            0.45, 0.54, 0.63, 0.72, 0.81, 0.90, 1.0
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text("Available Courses"),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF232022),
                  Color(0xFF432837),
                  Color(0xFF682C47),
                  Color(0xFF8F2D51),
                  Color(0xFFB72C54),
                ],
              ),
            ),
          ),
          elevation: 0,
        ),
        body: GridView.builder(
          padding: EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: MediaQuery.of(context).size.width < 600 ? 2 : 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          itemCount: courses.length,
          itemBuilder: (context, index) {
            var course = courses[index];
            return Card(
              elevation: 4,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("${course['name']} course details")),
                  );
                },
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        course['icon'],
                        size: 60,
                        color: course['color'],
                      ),
                      SizedBox(height: 16),
                      Text(
                        course['name'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        course['duration'],
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "${course['students']} Students",
                        style: TextStyle(
                          color: Color(0xFFB72C54),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Profile Screen
class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF232022),
            Color(0xFF432837),
            Color(0xFF682C47),
            Color(0xFF8F2D51),
            Color(0xFFB72C54),
            Color(0xFFBE345F),
            Color(0xFFC53B6B),
            Color(0xFFCC4377),
            Color(0xFFAC5486),
            Color(0xFF8C6088),
            Color(0xFF73657C),
            Color(0xFF666666),
          ],
          stops: [
            0.0, 0.09, 0.18, 0.27, 0.36,
            0.45, 0.54, 0.63, 0.72, 0.81, 0.90, 1.0
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text("Profile"),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF232022),
                  Color(0xFF432837),
                  Color(0xFF682C47),
                  Color(0xFF8F2D51),
                  Color(0xFFB72C54),
                ],
              ),
            ),
          ),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                elevation: 8,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Color(0xFFB72C54),
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Admin User",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFB72C54),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "admin@studentmanagement.com",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Chip(
                        label: Text("Administrator"),
                        backgroundColor: Color(0xFFB72C54).withOpacity(0.1),
                        labelStyle: TextStyle(color: Color(0xFFB72C54)),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Card(
                elevation: 4,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    buildProfileMenuItem(
                      Icons.person_outline,
                      "Personal Information",
                          () => ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Edit Personal Information")),
                      ),
                    ),
                    Divider(height: 1),
                    buildProfileMenuItem(
                      Icons.lock_outline,
                      "Change Password",
                          () => ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Change Password")),
                      ),
                    ),
                    Divider(height: 1),
                    buildProfileMenuItem(
                      Icons.notifications_outlined,
                      "Notifications",
                          () => ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Notification Settings")),
                      ),
                    ),
                    Divider(height: 1),
                    buildProfileMenuItem(
                      Icons.privacy_tip_outlined,
                      "Privacy Policy",
                          () => ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Privacy Policy")),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Card(
                elevation: 4,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    buildProfileMenuItem(
                      Icons.info_outline,
                      "About App",
                          () => showAboutDialog(
                        context: context,
                        applicationName: "Student Management System",
                        applicationVersion: "1.0.0",
                        applicationIcon: Icon(Icons.school, size: 40, color: Color(0xFFB72C54)),
                        children: [
                          Text("A modern student management system for educational institutions."),
                        ],
                      ),
                    ),
                    Divider(height: 1),
                    buildProfileMenuItem(
                      Icons.logout,
                      "Logout",
                          () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Logout"),
                              content: Text("Are you sure you want to logout?"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text("Cancel"),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (context) => LoginPage()),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  child: Text("Logout"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      isLogout: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildProfileMenuItem(IconData icon, String title, VoidCallback onTap, {bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon, color: isLogout ? Colors.red : Color(0xFFB72C54)),
      title: Text(
        title,
        style: TextStyle(color: isLogout ? Colors.red : null),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}

// Updated Search Delegate for Firestore
class StudentSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('students')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final results = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final name = data['name']?.toLowerCase() ?? '';
          final studentId = data['studentId']?.toLowerCase() ?? '';
          final email = data['email']?.toLowerCase() ?? '';
          final searchQuery = query.toLowerCase();

          return name.contains(searchQuery) ||
              studentId.contains(searchQuery) ||
              email.contains(searchQuery);
        }).toList();

        if (results.isEmpty) {
          return Center(
            child: Text(
              "No students found",
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final studentData = results[index].data() as Map<String, dynamic>;
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Color(0xFFB72C54),
                child: Text(studentData['name'][0].toUpperCase()),
              ),
              title: Text(studentData['name'] ?? ''),
              subtitle: Text("ID: ${studentData['studentId'] ?? ''}"),
              onTap: () {
                close(context, null);
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }
}

// Global Student Data Storage (keeping for compatibility)
class StudentData {
  static List<Student> students = [];
}