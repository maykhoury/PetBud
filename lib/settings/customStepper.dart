import 'package:flutter/material.dart';


const int theme_color = 0xFF0040A9;

class CustomStepper extends StatelessWidget {
  final int currentStep;
  final List<Step> steps;

  CustomStepper({required this.currentStep, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
           // Adjust this value as needed
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: steps.length,
            itemBuilder: (context, idx) {
              Step step = steps[idx];
              bool isCurrentStep = idx == currentStep;

              return Container(
                 // Adjust this value as needed
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isCurrentStep ? Colors.blue : Colors.grey,
                    child: Text(
                      '${idx + 1}',
                      style: TextStyle(color: isCurrentStep ? Colors.white : Colors.black),
                    ),
                  ),
                  title: step.title,
                ),
              );
            },
          ),
        ),
        // Expanded(
        //   child: IndexedStack(
        //     index: currentStep,
        //     children: steps.map((step) => step.content).toList(),
        //   ),
        // ),
      ],
    );
  }
}