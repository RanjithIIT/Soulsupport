import 'package:flutter/material.dart';

import 'activities.dart';
import 'add_student.dart';
import 'add_teacher.dart';
import 'admissions.dart';
import 'awards.dart';
import 'bus_routes.dart';
import 'buses.dart';
import 'calendar.dart';
import 'campus_life.dart';
import 'dashboard.dart';
import 'departments.dart';
import 'edit_activity.dart';
import 'edit_bus.dart';
import 'edit_student.dart';
import 'edit_teacher.dart';
import 'events.dart';
import 'examinations.dart';
import 'fees.dart';
import 'gallery.dart';
import 'notifications.dart';
import 'students.dart';
import 'teachers.dart';

void main() {
  runApp(const SchoolManagementApp());
}

class SchoolManagementApp extends StatelessWidget {
  const SchoolManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'School Management System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Segoe UI',
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      home: const DashboardPage(),
      routes: {
        '/dashboard': (_) => const DashboardPage(),
        '/teachers': (_) => const TeachersManagementPage(),
        '/students': (_) => const StudentsManagementPage(),
        '/buses': (_) => const BusesManagementPage(),
        '/activities': (_) => const ActivitiesManagementPage(),
        '/events': (_) => const EventsManagementPage(),
        '/notifications': (_) => const NotificationsManagementPage(),
        '/gallery': (_) => const PhotoGalleryPage(),
        '/fees': (_) => const FeesManagementPage(),
        '/examinations': (_) => const ExaminationManagementPage(),
        '/calendar': (_) => const CalendarManagementPage(),
        '/awards': (_) => const AwardsManagementPage(),
        '/admissions': (_) => const AdmissionsManagementPage(),
        '/bus-routes': (_) => const BusRoutesManagementPage(),
        '/campus-life': (_) => const CampusLifeManagementPage(),
        '/departments': (_) => const DepartmentsManagementPage(),
        '/add-student': (_) => const AddStudentPage(),
        '/add-teacher': (_) => const AddTeacherPage(),
        '/edit-student': (_) => const EditStudentPage(),
        '/edit-teacher': (_) => const EditTeacherPage(),
        '/edit-bus': (_) => const EditBusPage(),
        '/edit-activity': (_) => const EditActivityPage(),
      },
    );
  }
}

