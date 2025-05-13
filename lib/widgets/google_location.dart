import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PlacePrediction {
  final String placeId;
  final String description;

  PlacePrediction({required this.placeId, required this.description});

  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    return PlacePrediction(
        placeId: json['place_id'], description: json['description']);
  }
}

class CustomGooglePlacesField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String label;
  final ValueChanged<String> onChanged;
  final String googleApiKey;
  final bool isRequired;
  final String? errorText;

  const CustomGooglePlacesField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.label,
    required this.onChanged,
    required this.googleApiKey,
    this.isRequired = false,
    this.errorText,
  }) : super(key: key);

  @override
  State<CustomGooglePlacesField> createState() =>
      _CustomGooglePlacesFieldState();
}

class _CustomGooglePlacesFieldState extends State<CustomGooglePlacesField> {
  List<PlacePrediction> _predictions = [];
  bool _isLoading = false;
  Timer? _debounce;
  bool _showPredictions = false;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _getPlacePredictions(String input) async {
    if (input.isEmpty) {
      setState(() {
        _predictions = [];
        _isLoading = false;
        _showPredictions = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=${widget.googleApiKey}');

    try {
      final response = await http.get(url);
      final data = json.decode(response.body);

      if (data['status'] == 'OK') {
        final predictions = (data['predictions'] as List)
            .map((prediction) => PlacePrediction.fromJson(prediction))
            .toList();

        if (mounted) {
          setState(() {
            _predictions = predictions;
            _isLoading = false;
            _showPredictions = true;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _predictions = [];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _predictions = [];
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 5),
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              children: [
                TextSpan(text: widget.label),
                if (widget.isRequired)
                  const TextSpan(
                    text: " *",
                    style: TextStyle(color: Colors.red),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 5),

        // Input field
        // Container(
        //   width: double.infinity,
        //   decoration: BoxDecoration(
        //     borderRadius: BorderRadius.circular(5),
        //     color: Colors.white,
        //     border: widget.errorText != null
        //         ? Border.all(color: Colors.red, width: 1.0)
        //         : null,
        //   ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: const Color.fromARGB(255, 248, 247, 247),
            border: widget.errorText != null
                ? Border.all(color: Colors.red, width: 1.0)
                : null,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextField(
              minLines: 1,
              maxLines: null,
              controller: widget.controller,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle:
                    GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                border: InputBorder.none,
                suffixIcon: widget.controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          widget.controller.clear();
                          setState(() {
                            _predictions = [];
                            _showPredictions = false;
                          });
                          widget.onChanged('');
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                if (_debounce?.isActive ?? false) _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 500), () {
                  _getPlacePredictions(value);
                });
                widget.onChanged(value);
              },
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.done,
              onTap: () {
                if (_predictions.isNotEmpty) {
                  setState(() {
                    _showPredictions = true;
                  });
                }
              },
            ),
          ),
        ),

        // Error text
        if (widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 4),
            child: Text(
              widget.errorText!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),

        // Predictions list
        if (_showPredictions && (_predictions.isNotEmpty || _isLoading))
          Container(
            constraints: BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: _predictions.map((prediction) {
                        return InkWell(
                          onTap: () {
                            widget.controller.text = prediction.description;
                            widget.onChanged(prediction.description);
                            setState(() {
                              _showPredictions = false;
                            });
                            // Hide keyboard
                            FocusScope.of(context).unfocus();
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                const Icon(Icons.location_on, size: 18),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    prediction.description,
                                    style: TextStyle(fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
          ),
      ],
    );
  }
}
