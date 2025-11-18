import 'package:flutter/material.dart';
import 'profile_text_field_widget.dart';

class EditProfileFormWidget extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController professionController;
  final TextEditingController phoneController;
  final TextEditingController locationController;
  final TextEditingController bioController;
  final TextEditingController languageController;
  final String email;

  const EditProfileFormWidget({
    super.key,
    required this.usernameController,
    required this.professionController,
    required this.phoneController,
    required this.locationController,
    required this.bioController,
    required this.languageController,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProfileTextFieldWidget(
          controller: usernameController,
          label: "Username",
          icon: Icons.person_outline,
          validator: (val) => val!.isEmpty ? 'Username cannot be empty' : null,
        ),
        ProfileTextFieldWidget(
          controller: TextEditingController(text: email),
          label: "Email",
          icon: Icons.email_outlined,
          readOnly: true,
        ),
        ProfileTextFieldWidget(
          controller: professionController,
          label: "Profession (e.g., Real Estate Manager)",
          icon: Icons.work_outline,
        ),
        ProfileTextFieldWidget(
          controller: phoneController,
          label: "Phone",
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        ProfileTextFieldWidget(
          controller: locationController,
          label: "Location (e.g., Turbat, Balochistan)",
          icon: Icons.location_on_outlined,
        ),
        ProfileTextFieldWidget(
          controller: bioController,
          label: "Bio",
          icon: Icons.notes_outlined,
          maxLines: 3,
        ),
        ProfileTextFieldWidget(
          controller: languageController,
          label: "Languages (e.g., English, Balochi)",
          icon: Icons.language_outlined,
        ),
      ],
    );
  }
}