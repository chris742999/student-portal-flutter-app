// report_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportScreen extends StatefulWidget {
  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  bool _isLoading = true;
  String _errorMessage = '';

  // Statistics variables
  int _totalStudents = 0;
  int _totalCourses = 0;
  int _firstYear = 0;
  int _secondYear = 0;
  int _thirdYear = 0;
  int _fourthYear = 0;

  // Course enrollment
  Map<String, int> _courseEnrollment = {};
  List<String> _courses = [
    'Computer Science',
    'Engineering',
    'Business',
    'Mathematics',
    'Physics',
    'Chemistry'
  ];

  // Recent registrations
  List<Map<String, dynamic>> _recentRegistrations = [];

  // Most popular course
  String _mostPopularCourse = '';
  int _mostPopularCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchReportData();
  }

  Future<void> _fetchReportData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Get all students
      QuerySnapshot studentSnapshot = await FirebaseFirestore.instance
          .collection('students')
          .get();

      List<QueryDocumentSnapshot> students = studentSnapshot.docs;
      _totalStudents = students.length;

      // Reset counters
      _firstYear = 0;
      _secondYear = 0;
      _thirdYear = 0;
      _fourthYear = 0;

      // Initialize course enrollment
      Map<String, int> tempCourseEnrollment = {};
      for (String course in _courses) {
        tempCourseEnrollment[course] = 0;
      }

      // Process each student
      List<Map<String, dynamic>> tempRecent = [];

      for (var doc in students) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Count by year
        String year = data['year'] ?? '';
        if (year.contains('1st')) _firstYear++;
        else if (year.contains('2nd')) _secondYear++;
        else if (year.contains('3rd')) _thirdYear++;
        else if (year.contains('4th')) _fourthYear++;

        // Count by course
        String course = data['course'] ?? '';
        if (tempCourseEnrollment.containsKey(course)) {
          tempCourseEnrollment[course] = tempCourseEnrollment[course]! + 1;
        }

        // Add to recent list with timestamp
        tempRecent.add({
          'name': data['name'] ?? 'N/A',
          'studentId': data['studentId'] ?? 'N/A',
          'course': course,
          'year': year,
          'createdAt': data['createdAt'] ?? Timestamp.now(),
          'documentId': doc.id,
        });
      }

      _courseEnrollment = tempCourseEnrollment;

      // Sort recent registrations by createdAt (newest first)
      tempRecent.sort((a, b) {
        Timestamp aTime = a['createdAt'] as Timestamp? ?? Timestamp.now();
        Timestamp bTime = b['createdAt'] as Timestamp? ?? Timestamp.now();
        return bTime.compareTo(aTime);
      });

      _recentRegistrations = tempRecent.take(5).toList();

      // Calculate most popular course
      _mostPopularCount = 0;
      _mostPopularCourse = 'N/A';
      _courseEnrollment.forEach((course, count) {
        if (count > _mostPopularCount) {
          _mostPopularCount = count;
          _mostPopularCourse = course;
        }
      });

      // Count total courses with students
      _totalCourses = _courseEnrollment.values.where((count) => count > 0).length;

      setState(() {
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading data: $e';
      });
      print('Firestore Error: $e');
    }
  }

  Future<void> _refreshData() async {
    await _fetchReportData();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Data refreshed successfully'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
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
        appBar: AppBar(
          title: Text(
            "Analytics Report",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
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
              icon: Icon(Icons.refresh),
              onPressed: _refreshData,
              tooltip: 'Refresh Data',
            ),
          ],
        ),
        body: _isLoading
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB72C54)),
              ),
              SizedBox(height: 16),
              Text(
                'Loading report data...',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        )
            : _errorMessage.isNotEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.orange,
              ),
              SizedBox(height: 16),
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchReportData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFB72C54),
                ),
                child: Text('Retry'),
              ),
            ],
          ),
        )
            : SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                "Enrollment Analytics",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Real-time student statistics and insights",
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
              SizedBox(height: 24),

              // Statistics Cards Row
              _buildStatsGrid(),
              SizedBox(height: 24),

              // Students by Course Section
              _buildCourseSection(),
              SizedBox(height: 24),

              // Recent Registrations Section
              _buildRecentRegistrations(),
              SizedBox(height: 24),

              // Visual Charts Section
              _buildChartsSection(),
              SizedBox(height: 24),

              // Report Summary Section
              _buildReportSummary(),
              SizedBox(height: 24),

              // Export Button
              _buildExportButton(),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: _getCrossAxisCount(context),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard(
          'Total Students',
          '$_totalStudents',
          Icons.people,
          Color(0xFFB72C54),
          '👨‍🎓',
        ),
        _buildStatCard(
          'Total Courses',
          '$_totalCourses',
          Icons.book,
          Colors.orange,
          '📚',
        ),
        _buildStatCard(
          '1st Year',
          '$_firstYear',
          Icons.looks_one,
          Colors.blue,
          '🎓',
        ),
        _buildStatCard(
          '2nd Year',
          '$_secondYear',
          Icons.looks_two,
          Colors.green,
          '📖',
        ),
        _buildStatCard(
          '3rd Year',
          '$_thirdYear',
          Icons.looks_3,
          Colors.purple,
          '⚡',
        ),
        _buildStatCard(
          '4th Year',
          '$_fourthYear',
          Icons.looks_4,
          Colors.teal,
          '🏆',
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, String emoji) {
    return Card(
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 28, color: color),
                Text(
                  emoji,
                  style: TextStyle(fontSize: 24),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseSection() {
    return Card(
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.school, color: Color(0xFFB72C54), size: 24),
                SizedBox(width: 8),
                Text(
                  "Students by Course",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB72C54),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ..._courses.map((course) {
              int count = _courseEnrollment[course] ?? 0;
              double percentage = _totalStudents > 0 ? (count / _totalStudents) * 100 : 0;
              return Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          course,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '$count students',
                          style: TextStyle(
                            color: Color(0xFFB72C54),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getCourseColor(course),
                      ),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentRegistrations() {
    return Card(
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.access_time, color: Color(0xFFB72C54), size: 24),
                SizedBox(width: 8),
                Text(
                  "Recent Registrations",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB72C54),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (_recentRegistrations.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    "No recent registrations",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _recentRegistrations.length,
                separatorBuilder: (context, index) => Divider(),
                itemBuilder: (context, index) {
                  var student = _recentRegistrations[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Color(0xFFB72C54),
                      child: Text(
                        student['name'][0].toUpperCase(),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      student['name'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'ID: ${student['studentId']} • ${student['course']} • ${student['year']}',
                      style: TextStyle(fontSize: 12),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsSection() {
    return Card(
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.pie_chart, color: Color(0xFFB72C54), size: 24),
                SizedBox(width: 8),
                Text(
                  "Visual Distribution",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB72C54),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Year Distribution
            Text(
              "Student Distribution by Year",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildYearProgressBar('1st', _firstYear, Colors.blue),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _buildYearProgressBar('2nd', _secondYear, Colors.green),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _buildYearProgressBar('3rd', _thirdYear, Colors.purple),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _buildYearProgressBar('4th', _fourthYear, Colors.teal),
                ),
              ],
            ),
            SizedBox(height: 24),

            // Course Distribution (Simple Pie Chart representation)
            Text(
              "Course Distribution",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _courses.map((course) {
                int count = _courseEnrollment[course] ?? 0;
                double percentage = _totalStudents > 0 ? (count / _totalStudents) * 100 : 0;
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _getCourseColor(course).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getCourseColor(course),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '$course: ${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _getCourseColor(course),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYearProgressBar(String year, int count, Color color) {
    double percentage = _totalStudents > 0 ? (count / _totalStudents) * 100 : 0;
    return Column(
      children: [
        Container(
          height: 60,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              Container(
                height: 60,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: percentage * 0.6,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 4),
        Text(
          year,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        Text(
          '$count',
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildReportSummary() {
    return Card(
      elevation: 4,
      color: Color(0xFFB72C54).withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Color(0xFFB72C54), width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.summarize, color: Color(0xFFB72C54), size: 24),
                SizedBox(width: 8),
                Text(
                  "Report Summary",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB72C54),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildSummaryRow(
              'Total Students Registered:',
              '$_totalStudents',
              Icons.people,
            ),
            SizedBox(height: 12),
            _buildSummaryRow(
              'Most Popular Course:',
              '$_mostPopularCourse ($_mostPopularCount students)',
              Icons.emoji_events,
            ),
            SizedBox(height: 12),
            _buildSummaryRow(
              'Available Courses:',
              '$_totalCourses',
              Icons.bookmark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Color(0xFFB72C54)),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Color(0xFFB72C54),
          ),
        ),
      ],
    );
  }

  Widget _buildExportButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          // Future PDF export implementation
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Export feature coming soon! PDF generation will be implemented.'),
              backgroundColor: Color(0xFFB72C54),
              duration: Duration(seconds: 3),
            ),
          );
        },
        icon: Icon(Icons.download, color: Colors.white),
        label: Text(
          'EXPORT REPORT',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFB72C54),
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
      ),
    );
  }

  Color _getCourseColor(String course) {
    switch (course) {
      case 'Computer Science':
        return Colors.blue;
      case 'Engineering':
        return Colors.green;
      case 'Business':
        return Colors.orange;
      case 'Mathematics':
        return Colors.purple;
      case 'Physics':
        return Colors.red;
      case 'Chemistry':
        return Colors.teal;
      default:
        return Color(0xFFB72C54);
    }
  }

  int _getCrossAxisCount(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width < 600) return 2;
    if (width < 900) return 3;
    return 4;
  }
}