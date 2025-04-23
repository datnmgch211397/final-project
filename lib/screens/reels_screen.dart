import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../widgets/reel_item.dart';

class ReelsScreen extends StatefulWidget {
  final int? initialIndex;
  final List<QueryDocumentSnapshot<Object?>>? initialReels;

  const ReelsScreen({super.key, this.initialIndex, this.initialReels});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex ?? 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If we have initial reels, show them directly
    if (widget.initialReels != null) {
      return Scaffold(
        body: SafeArea(
          child: PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: widget.initialReels!.length,
            itemBuilder: (context, index) {
              final data =
                  widget.initialReels![index].data() as Map<String, dynamic>;
              return ReelItem(data);
            },
          ),
        ),
      );
    }

    // Otherwise, load all reels from Firestore
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream:
              _firestore
                  .collection('reels')
                  .orderBy('time', descending: true)
                  .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No reels available'));
            }

            return PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final data =
                    snapshot.data!.docs[index].data() as Map<String, dynamic>;
                return ReelItem(data);
              },
            );
          },
        ),
      ),
    );
  }
}
