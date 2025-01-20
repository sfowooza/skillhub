import 'package:appwrite/models.dart';


import 'package:flutter/material.dart';
import 'package:skillhub/controllers/formart_datetime.dart';
import 'package:skillhub/pages/homePages/skills_detail.dart';


class PopularItem extends StatelessWidget {
  final int index;

  final Document eventData;
  const PopularItem({super.key, required this.index, required this.eventData});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SkillDetails(
                    data: eventData,
                  ))),
      minLeadingWidth: 0,
      minVerticalPadding: 10,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Text(
        "$index.",
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
      title: Text(
        eventData.data["firstName"],
        style: const TextStyle(fontSize: 18, color: Colors.white),
      ),
      subtitle: Column(
        children: [
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.calendar_month_outlined,
                  size: 18, color: Colors.white),
              const SizedBox(width: 4),
              Text(
                formatDate(eventData.data["datetime"]),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(width: 14),
              const Icon(Icons.access_time_rounded,
                  size: 18, color: Colors.white),
              const SizedBox(width: 4),
              Text(
                formatTime(eventData.data["datetime"]),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 18, color: Colors.white),
              const SizedBox(width: 4),
              Text(
                eventData.data["location"],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
      textColor: Colors.white,
    );
  }
}