import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:iconsax/iconsax.dart';

import '../theme/brand_colors.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Image Slider
          _buildImageSlider(),
          const SizedBox(height: 30),

          // Our Faculties Section
          _buildFacultiesSection(),
          const SizedBox(height: 30),

          // Our Achievements Section
          _buildAchievementsSection(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildImageSlider() {
    final List<String> sliderImages = [
      'assets/slider/1.jpeg',
      'assets/slider/2.jpeg',
      'assets/slider/3.jpeg',
      'assets/slider/4.jpeg',
    ];

    return CarouselSlider(
      options: CarouselOptions(
        height: 250,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 3),
        enlargeCenterPage: true,
        viewportFraction: 0.9,
      ),
      items: sliderImages.map((imagePath) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(imagePath, fit: BoxFit.cover),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildFacultiesSection() {
    return Column(
      children: [
        const Text(
          'OUR FACULTIES',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: BrandColors.accent,
          ),
        ),
        const SizedBox(height: 20),
        _buildFacultyCard(
          icon: Icons.health_and_safety,
          title: 'FACULTY OF HEALTH SCIENCE',
          description: 'The faculty aims to offer high quality innovative teaching and research at every scale. And well train individuals to contribute to the development of health sector of the country.',
          color: Colors.red,
        ),
        _buildFacultyCard(
          icon: Icons.account_balance,
          title: 'FACULTY OF ECONOMICS & MANAGEMENT SCIENCE',
          description: 'The Faculty of Economic and Management Sciences is one of the largest Faculties at the University. The Faculty aims to continuously strengthen its position as the leading institution in the fields of economics',
          color: Colors.green,
        ),
        _buildFacultyCard(
          icon: Icons.computer,
          title: 'FACULTY OF COMPUTER SCIENCE & ENGINEERING',
          description: 'If you are interested in the field of software engineering and programming the faculty of Computer Science and Engineering is the right place for you.',
          color: Colors.blue,
        ),
        _buildFacultyCard(
          icon: Icons.local_hospital,
          title: 'FACULTY OF MEDICINE & SURGERY',
          description: 'Admission to the CUS faculty of Medicine & Surgery is extremely tough and selective. We are committed to innovation, excellence, and work to advance social equality and health',
          color: Colors.pink,
        ),
        _buildFacultyCard(
          icon: Icons.eco,
          title: 'FACULTY OF AGRICULTURE & ENVIRONMENTAL SCIENCE',
          description: 'Through research-based instruction, the Faculty of Agricultural & Environmental Science seeks to advance the wise use of the earth\'s natural resources.',
          color: Colors.teal,
        ),
        _buildFacultyCard(
          icon: Icons.gavel,
          title: 'FACULTY OF SHARIA & LAW',
          description: 'The Faculty of Sharia and Law is set up to simultaneously educate Sharia and formal law in order to produce highly competent legal cadres who could bridge the current, obvious deficiencies in Somalia\'s legal profession',
          color: Colors.brown,
        ),
        _buildFacultyCard(
          icon: Icons.school,
          title: 'FACULTY OF EDUCATION',
          description: 'The Faculty of Education focus on producing qualified teachers, specialized for every subject needed in secondary schools (and related institutions) and also undergraduate level,',
          color: Colors.orange,
        ),
        _buildFacultyCard(
          icon: Icons.people,
          title: 'FACULTY OF SOCIAL SCIENCES',
          description: 'Faculty of Social Sciences is to educate professionals in the fields of Political Science and International Affairs, satisfy the region\'s present and future demands.',
          color: Colors.purple,
        ),
        _buildFacultyCard(
          icon: Icons.workspace_premium,
          title: 'DIPLOMA & INSTITUTIONS',
          description: 'to enhance the skills and knowledge of Somali students, Capital University has it for you; DIPLOMA IN EDUCATION & Dr. KADARE INSTITUTE OF CULTURE & LANGUAGES',
          color: Colors.indigo,
          buttonText: 'Read More',
        ),
      ],
    );
  }

  Widget _buildFacultyCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    String buttonText = 'Apply Now',
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 35,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(height: 15),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: BrandColors.accent,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: BrandColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: BrandColors.accent.withOpacity(0.1),
      ),
      child: Column(
        children: [
          const Text(
            'OUR ACHIEVEMENTS',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: BrandColors.accent,
            ),
          ),
          const SizedBox(height: 30),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              _buildAchievementCard('Faculties', '8'),
              _buildAchievementCard('Departments', '14+'),
              _buildAchievementCard('ALUMNI', '1,000+'),
              _buildAchievementCard('Postgraduate Alumni', '100+'),
              _buildAchievementCard('Current Students', '2,000+'),
              _buildAchievementCard('Campuses', '2'),
              _buildAchievementCard('Labs', '10'),
              _buildAchievementCard('External Relations', '20+'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(String title, String value) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: BrandColors.accent,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}
