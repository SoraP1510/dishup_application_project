import 'package:flutter/material.dart';

class CreateInfoPage extends StatefulWidget {
  const CreateInfoPage({super.key});

  @override
  State<CreateInfoPage> createState() => _CreateInfoPageState();
}

class _CreateInfoPageState extends State<CreateInfoPage> {
  String? selectedGender;

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();

  final List<String> genderOptions = ['Male', 'Female', 'Prefer not to answer'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back arrow
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context), //This one doesn't return to the before page
              ),
              const SizedBox(height: 10),

              const Text(
                'ENTER YOUR INFO',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 25),

              const _Label("Gender"),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey[100],
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: DropdownButtonFormField<String>(
                  value: selectedGender,
                  hint: const Text("Gender"),
                  decoration: const InputDecoration(border: InputBorder.none),
                  items: genderOptions
                      .map((gender) => DropdownMenuItem(
                            value: gender,
                            child: Text(gender),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedGender = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),

              const _Label("USERNAME"),
              _inputField("Username", usernameController),
              const SizedBox(height: 20),

              const _Label("AGE"),
              _inputField("Age", ageController,
                  inputType: TextInputType.number),
              const SizedBox(height: 20),

              const _Label("WEIGHT (Kilogram)"),
              _inputField("Weight", weightController,
                  inputType: TextInputType.number),
              const SizedBox(height: 20),

              const _Label("HEIGHT (Centimeter)"),
              _inputField("Height", heightController,
                  inputType: TextInputType.number),
              const SizedBox(height: 40),

              // Finish Button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Handle finish logic here
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6DDC5A),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'FINISH',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, color: Colors.white),
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

  Widget _inputField(String hint, TextEditingController controller,
      {TextInputType inputType = TextInputType.text}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 4)),
        ],
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        decoration: InputDecoration(
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
    );
  }
}
