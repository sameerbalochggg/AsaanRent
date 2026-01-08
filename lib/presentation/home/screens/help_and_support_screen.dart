import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

// ✅ --- ERROR HANDLER IMPORT ---
import 'package:asaan_rent/core/utils/error_handler.dart';

class HelpAndSupportScreen extends StatefulWidget {
  const HelpAndSupportScreen({super.key});

  @override
  State<HelpAndSupportScreen> createState() => _HelpAndSupportScreenState();
}

class _HelpAndSupportScreenState extends State<HelpAndSupportScreen> {
  // FAQ Data
  final List<Map<String, String>> _faqs = [
    {
      'question': 'How do I add a property listing?',
      'answer':
          'Go to your profile, tap "Add Property", fill in the property details including images, location, and pricing, then submit.'
    },
    {
      'question': 'How can I edit my property?',
      'answer':
          'Navigate to "My Properties" in your profile, select the property you want to edit, and tap the edit icon.'
    },
    {
      'question': 'How do I search for properties?',
      'answer':
          'Use the search icon in the home screen. You can filter by property type, location, and price range.'
    },
    {
      'question': 'How do I mark a property as favorite?',
      'answer':
          'Tap the heart icon on any property card to add it to your favorites. Access favorites from the bottom navigation.'
    },
    {
      'question': 'How do I contact a property owner?',
      'answer':
          'Open the property details page and use the contact options (phone or email) provided by the owner.'
    },
    {
      'question': 'Can I update my profile information?',
      'answer':
          'Yes! Go to your profile screen and tap the edit icon in the top right corner to update your details.'
    },
    {
      'question': 'How do I reset my password?',
      'answer':
          'On the login screen, tap "Forgot Password", enter your email, and follow the instructions sent to your inbox.'
    },
    {
      'question': 'Is my data secure?',
      'answer':
          'Yes, we use industry-standard encryption and secure authentication to protect your data.'
    },
  ];

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not launch $url');
      }
    } catch (error) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(context, error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: theme.primaryColor,
        title: Text(
          'Help & Support',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            _buildWelcomeCard(theme),
            const SizedBox(height: 24),

            // Quick Actions
            _buildQuickActions(theme),
            const SizedBox(height: 24),

            // FAQs Section
            _buildSectionHeader(theme, 'Frequently Asked Questions', Icons.help_outline),
            const SizedBox(height: 12),
            _buildFAQList(),
            const SizedBox(height: 24),

            // Contact Us Section
            _buildSectionHeader(theme, 'Contact Us', Icons.contact_support),
            const SizedBox(height: 12),
            _buildContactOptions(theme),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.support_agent,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'We\'re Here to Help!',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Get assistance anytime',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionCard(
            theme,
            'Email Us',
            Icons.email_outlined,
            () => _launchURL('mailto:sameerbalochggg55@gmail.com'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionCard(
            theme,
            'Call Us',
            Icons.phone_outlined,
            () => _launchURL('tel:+923232635195'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionCard(
            theme,
            'WhatsApp',
            Icons.chat_bubble_outline,
            () => _launchURL('https://wa.me/923232635195'),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    ThemeData theme,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          children: [
            Icon(icon, color: theme.primaryColor, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: theme.primaryColor, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildFAQList() {
    return Column(
      children: _faqs.map((faq) => _buildFAQItem(faq)).toList(),
    );
  }

  Widget _buildFAQItem(Map<String, String> faq) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Text(
            faq['question']!,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          iconColor: theme.primaryColor,
          collapsedIconColor: theme.textTheme.bodyMedium?.color,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                faq['answer']!,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: theme.textTheme.bodySmall?.color,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactOptions(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: [
          _buildContactItem(
            theme,
            Icons.email_outlined,
            'Email',
            'sameerbalochggg55@gmail.com',
            () => _launchURL('mailto:sameerbalochggg55@gmail.com'),
          ),
          const Divider(height: 24),
          _buildContactItem(
            theme,
            Icons.phone_outlined,
            'Phone',
            '+92 3232635195',
            () => _launchURL('tel:+923232635195'),
          ),
          const Divider(height: 24),
          _buildContactItem(
            theme,
            Icons.chat_bubble_outline,
            'WhatsApp',
            '+92 3232635195',
            () => _launchURL('https://wa.me/923232635195'),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(
    ThemeData theme,
    IconData icon,
    String title,
    String value,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: theme.primaryColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: theme.textTheme.bodySmall?.color,
            ),
          ],
        ),
      ),
    );
  }
}