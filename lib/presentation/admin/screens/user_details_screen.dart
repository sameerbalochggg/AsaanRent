import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:rent_application/data/models/user_profile_model.dart';
import 'package:rent_application/data/models/property_model.dart';
import 'package:rent_application/data/repositories/property_repository.dart';
import 'package:rent_application/presentation/property/screens/property_details_screen.dart';

class UserDetailsScreen extends StatefulWidget {
  final UserProfile user;

  const UserDetailsScreen({super.key, required this.user});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  final PropertyRepository _propertyRepo = PropertyRepository();
  
  List<Property> _userProperties = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProperties();
  }

  Future<void> _loadUserProperties() async {
    setState(() => _isLoading = true);
    try {
      // The userId passed in user.userId is the UUID from auth.users which matches owner_id in properties
      final properties = await _propertyRepo.fetchPropertiesByUserId(widget.user.userId);
      if (mounted) {
        setState(() {
          _userProperties = properties;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading properties: $e")),
        );
      }
    }
  }

  void _navigateToPropertyDetails(String propertyId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PropertyDetailsPage(propertyId: propertyId),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MMM dd, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "User Details", 
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold)
        ),
        backgroundColor: Colors.red[800], // Admin specific color
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // User Profile Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Avatar
                  widget.user.avatarUrl != null && widget.user.avatarUrl!.isNotEmpty
                      ? CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(widget.user.avatarUrl!),
                          backgroundColor: Colors.grey[300],
                        )
                      : CircleAvatar(
                          backgroundColor: Colors.red[800],
                          radius: 50,
                          child: Text(
                            (widget.user.username?.isNotEmpty == true) 
                                ? widget.user.username![0].toUpperCase() 
                                : '?',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 40,
                            ),
                          ),
                        ),
                  
                  const SizedBox(height: 16),
                  
                  // Username
                  Text(
                    widget.user.username ?? 'Unknown User',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Role Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: widget.user.role == 'admin' 
                          ? Colors.red[100] 
                          : Colors.blue[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.user.role.toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: widget.user.role == 'admin' 
                            ? Colors.red[800] 
                            : Colors.blue[800],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // User Info Cards
                  if (widget.user.profession != null && widget.user.profession!.isNotEmpty)
                    _buildInfoRow(
                      icon: Icons.work,
                      label: "Profession",
                      value: widget.user.profession!,
                      theme: theme,
                    ),
                  
                  if (widget.user.profession != null && widget.user.profession!.isNotEmpty)
                    const SizedBox(height: 12),
                  
                  if (widget.user.phone != null && widget.user.phone!.isNotEmpty)
                    _buildInfoRow(
                      icon: Icons.phone,
                      label: "Phone",
                      value: widget.user.phone!,
                      theme: theme,
                    ),
                  
                  if (widget.user.phone != null && widget.user.phone!.isNotEmpty)
                    const SizedBox(height: 12),
                  
                  if (widget.user.location != null && widget.user.location!.isNotEmpty)
                    _buildInfoRow(
                      icon: Icons.location_on,
                      label: "Location",
                      value: widget.user.location!,
                      theme: theme,
                    ),
                  
                  if (widget.user.location != null && widget.user.location!.isNotEmpty)
                    const SizedBox(height: 12),
                  
                  if (widget.user.language != null && widget.user.language!.isNotEmpty)
                    _buildInfoRow(
                      icon: Icons.language,
                      label: "Language",
                      value: widget.user.language!,
                      theme: theme,
                    ),
                  
                  if (widget.user.language != null && widget.user.language!.isNotEmpty)
                    const SizedBox(height: 12),
                  
                  _buildInfoRow(
                    icon: Icons.calendar_today,
                    label: "Joined",
                    value: _formatDate(widget.user.createdAt),
                    theme: theme,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _buildInfoRow(
                    icon: Icons.fingerprint,
                    label: "User ID",
                    value: widget.user.userId,
                    theme: theme,
                    isSmall: true,
                  ),
                  
                  if (widget.user.bio != null && widget.user.bio!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info, size: 20, color: Colors.red[800]),
                              const SizedBox(width: 12),
                              Text(
                                "Bio",
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.user.bio!,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Properties Section Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Posted Properties",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red[800],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "${_userProperties.length}",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Properties List
            _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  )
                : _userProperties.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.home_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No properties posted yet",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _userProperties.length,
                        itemBuilder: (context, index) {
                          final property = _userProperties[index];
                          return _buildPropertyCard(property, theme);
                        },
                      ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
    bool isSmall = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.red[800]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: isSmall ? 11 : 14,
                    fontWeight: FontWeight.w500,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                  maxLines: isSmall ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyCard(Property property, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        onTap: () => _navigateToPropertyDetails(property.id),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Property Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: (property.images != null && property.images!.isNotEmpty)
                    ? Image.network(
                        property.images!.first,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, st) => _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),
              
              const SizedBox(width: 12),
              
              // Property Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            property.displayName,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (property.isVerified)
                          const Icon(Icons.verified, size: 18, color: Colors.blue),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      property.displayLocation,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Rs ${property.displayPrice}/month",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[800],
                      ),
                    ),
                  ],
                ),
              ),
              
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 80,
      height: 80,
      color: Colors.grey[300],
      child: const Icon(Icons.home, color: Colors.grey, size: 40),
    );
  }
}