import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class TaleCardShimmer extends StatelessWidget {
  const TaleCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        children: [
          Container(
            height: 250,
            decoration: ShapeDecoration(
              color: Colors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              SizedBox(width: 8,),
              Container(
                width: 120,
                height: 14,
                decoration: ShapeDecoration(
                  color: Colors.grey,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),
              Spacer(),
              Icon(Icons.more_vert),
              SizedBox(width: 8,),
            ],
          ),
        ],
      ),
    );
  }
}
