import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class MapsLauncher {
  /// Launches Google Maps with the provided location URL
  static Future<void> launchGoogleMaps(String locationUrl, BuildContext context) async {
    try {
      List<Uri> urlsToTry = [];
      
      // Check if the locationUrl is already a valid URL
      if (locationUrl.startsWith('http://') || locationUrl.startsWith('https://')) {
        urlsToTry.add(Uri.parse(locationUrl));
      } else {
        // Create multiple URL formats to try
        String encodedLocation = Uri.encodeComponent(locationUrl);
        
        // Try different Google Maps URL formats
        urlsToTry.addAll([
          Uri.parse('https://maps.google.com/maps?q=$encodedLocation'),
          Uri.parse('https://www.google.com/maps/search/?api=1&query=$encodedLocation'),
          Uri.parse('geo:0,0?q=$encodedLocation'),
          Uri.parse('google.navigation:q=$encodedLocation'),
        ]);
      }
      
      bool launched = false;
      for (Uri url in urlsToTry) {
        try {
          if (await canLaunchUrl(url)) {
            await launchUrl(
              url, 
              mode: LaunchMode.externalApplication,
            );
            launched = true;
            break;
          }
        } catch (e) {
          // Continue to next URL if this one fails
          continue;
        }
      }
      
      if (!launched) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.couldNotOpenGoogleMaps),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.errorOpeningLocation(e.toString())),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Launches WhatsApp with the provided phone number
  static Future<void> launchWhatsApp(String phoneNumber, BuildContext context) async {
    try {
      // Remove any non-digit characters and ensure it starts with country code
      String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      if (!cleanNumber.startsWith('+')) {
        cleanNumber = '+$cleanNumber';
      }
      
      final Uri url = Uri.parse('https://wa.me/$cleanNumber');
      
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open WhatsApp'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening WhatsApp: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Launches a web URL (Facebook, Instagram, Website)
  static Future<void> launchWebUrl(String url, BuildContext context) async {
    try {
      final Uri uri = Uri.parse(url);
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open URL'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening URL: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
