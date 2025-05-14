import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:smart_assist/config/component/color/colors.dart';
import 'package:smart_assist/config/component/font/font.dart';
import 'package:smart_assist/utils/storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_assist/services/leads_srv.dart';
import 'package:smart_assist/utils/snackbar_helper.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class TestdriveTeams extends StatefulWidget {
  final Function onFormSubmit;
  const TestdriveTeams({super.key, required this.onFormSubmit});

  @override
  State<TestdriveTeams> createState() => _TestdriveTeamsState();
}

class _TestdriveTeamsState extends State<TestdriveTeams> {
  // final PageController _pageController = PageController();
  List<Map<String, String>> dropdownItems = [];
  bool isLoading = false;

  bool _isLoadingSearch = false;
  bool _isLoadingSearch1 = false;
  String _query = '';
  String _query1 = '';
  String? selectedLeads;
  String? selectedLeadsName;
  String? selectedPriority;
  List<dynamic> vehicleList = [];
  List<String> uniqueVehicleNames = [];
  String? selectedVehicleName;
  List<dynamic> _searchResults = [];
  List<dynamic> _searchResults1 = [];
  // List<dynamic> _searchResults = [];
  List<String> colorOptions = [];
  String? selectedColor;
  String? selectedExteriorColor;
  String? selectedInteriorColor;
  List<String> exteriorOptions = [];
  List<String> interiorOptions = [];
  late stt.SpeechToText _speech;
  bool _isListening = false;

  bool _isLoadingAssignee = false;
  String? spId;
  String _assigneeQuery = '';
  List<dynamic> _searchResultsAssignee = [];
  String? selectedAssigneName;
  String? selectedAssigne;
  String? selectedAssigneEmail;

  // List<dynamic> _searchResults = [];
  List<dynamic> vehicleName = [];

  final TextEditingController _searchController1 = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  TextEditingController startTimeController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController _searchControllerAssignee =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    // fetchDropdownData();
    _searchControllerAssignee.addListener(_onAssigneeSearchChanged);

    _searchController1.addListener(_onSearchChanged1);

    _speech = stt.SpeechToText();
    _initSpeech();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController1.removeListener(_onSearchChanged1);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchAssigneeSearchResults(String query) async {
    print(
        "Inside _fetchAssigneeSearchResults with query: '$query'"); // Debug print

    if (query.isEmpty) {
      setState(() {
        _searchResultsAssignee.clear();
      });
      return;
    }

    setState(() {
      _isLoadingAssignee = true;
    });

    try {
      final token = await Storage.getToken();
      print(
          "Token retrieved: ${token != null ? 'Yes' : 'No'}"); // Debug token presence

      final apiUrl =
          'https://dev.smartassistapp.in/api/search/users?user=$query';
      print("API URL: $apiUrl"); // Debug URL

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print(
          "API Response status: ${response.statusCode}"); // Debug response code
      print("API Response body: ${response.body}"); // Debug response data

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          // _searchResultsAssignee = data['data']['suggestions'] ?? [];
          _searchResultsAssignee = data['data']['results'] ?? [];

          print(
              "Search results loaded: ${_searchResultsAssignee.length}"); // Debug results
        });
      } else {
        print("API error: ${response.statusCode} - ${response.body}");
        showErrorMessage(context, message: 'API Error: ${response.statusCode}');
      }
    } catch (e) {
      print("Exception during API call: $e"); // Debug exception
      showErrorMessage(context, message: 'Something went wrong..! $e');
    } finally {
      setState(() {
        _isLoadingAssignee = false;
      });
    }
  }

  void _onAssigneeSearchChanged() {
    final newQuery = _searchControllerAssignee.text.trim();
    if (newQuery == _assigneeQuery) return;

    _assigneeQuery = newQuery;
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_assigneeQuery == _searchControllerAssignee.text.trim()) {
        _fetchAssigneeSearchResults(_assigneeQuery);
      }
    });
  }

  // Initialize speech recognition
  void _initSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done') {
          setState(() {
            _isListening = false;
          });
        }
      },
      onError: (errorNotification) {
        setState(() {
          _isListening = false;
        });
        showErrorMessage(context,
            message: 'Speech recognition error: ${errorNotification.errorMsg}');
      },
    );
    if (!available) {
      showErrorMessage(context,
          message: 'Speech recognition not available on this device');
    }
  }

  // Toggle listening
  void _toggleListening(TextEditingController controller) async {
    if (_isListening) {
      _speech.stop();
      setState(() {
        _isListening = false;
      });
    } else {
      setState(() {
        _isListening = true;
      });

      await _speech.listen(
        onResult: (result) {
          setState(() {
            controller.text = result.recognizedWords;
          });
        },
        listenFor: Duration(seconds: 30),
        pauseFor: Duration(seconds: 5),
        partialResults: true,
        cancelOnError: true,
        listenMode: stt.ListenMode.confirmation,
      );
    }
  }

  Future<void> fetchVehicleData(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults1 = [];
        _isLoadingSearch1 = false;
      });
      return;
    }

    final token = await Storage.getToken();

    setState(() {
      _isLoadingSearch1 = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
          'https://dev.smartassistapp.in/api/search/vehicles?vehicle=${Uri.encodeComponent(query)}',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> results = data['data']['suggestions'] ?? [];

        final Set<String> seenNames = {};
        final List<dynamic> uniqueResults = [];

        for (var vehicle in results) {
          final name = vehicle['vehicle_name'];
          if (name != null && seenNames.add(name)) {
            uniqueResults.add(vehicle);
          }
        }

        if (_searchResults1 != uniqueResults) {
          // Avoid unnecessary updates
          setState(() {
            _searchResults1 = uniqueResults;
          });
        }
      } else {
        print("Failed to load data: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching data: $e");
    } finally {
      setState(() {
        _isLoadingSearch1 = false;
      });
    }
  }

  Future<void> fetchVehicleColors(String vehicleName) async {
    final token = await Storage.getToken();
    final encodedName = Uri.encodeComponent(vehicleName);

    final url =
        'https://dev.smartassistapp.in/api/users/vehicles/all?vehicle_name=$encodedName';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> vehicles = data['data']['rows'] ?? [];

        if (vehicles.isNotEmpty) {
          final vehicle = vehicles.first;
          final String? exterior = vehicle['exterior_color'];
          final String? interior = vehicle['interior_color'];

          setState(() {
            exteriorOptions =
                (exterior != null && exterior.isNotEmpty) ? [exterior] : [];
            interiorOptions =
                (interior != null && interior.isNotEmpty) ? [interior] : [];
            selectedExteriorColor = null;
            selectedInteriorColor = null;
          });
        }
      } else {
        print('Failed to fetch color data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching colors: $e');
    }
  }

  /// Fetch search results from API
  Future<void> _fetchSearchResults(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults.clear();
      });
      return;
    }

    setState(() {
      _isLoadingSearch = true;
    });

    final token = await Storage.getToken();

    try {
      final response = await http.get(
        Uri.parse(
            'https://dev.smartassistapp.in/api/search/global?query=$query'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          _searchResults = data['data']['suggestions'] ?? [];
        });
      }
    } catch (e) {
      showErrorMessage(context, message: 'Something went wrong..!');
    } finally {
      setState(() {
        _isLoadingSearch = false;
      });
    }
  }

  void _onSearchChanged() {
    final newQuery = _searchController.text.trim();
    if (newQuery == _query) return;

    _query = newQuery; // Correctly update _query here
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_query == _searchController.text.trim()) {
        _fetchSearchResults(_query);
      }
    });
  }

  void _onSearchChanged1() {
    final newQuery = _searchController1.text.trim();
    if (newQuery == _query1) return;

    _query1 = newQuery; // This should be updated to use _query1
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_query1 == _searchController1.text.trim()) {
        fetchVehicleData(_query1); // Pass the correct query1 here
      }
    });
  }

  Future<void> _pickDate({required bool isStartDate}) async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));
    if (pickedDate != null) {
      TimeOfDay? pickedTime =
          await showTimePicker(context: context, initialTime: TimeOfDay.now());
      if (pickedTime != null) {
        DateTime combinedDateTime = DateTime(pickedDate.year, pickedDate.month,
            pickedDate.day, pickedTime.hour, pickedTime.minute);
        String formattedDateTime =
            DateFormat('dd/MM/yyyy hh:mm a').format(combinedDateTime);
        setState(() {
          if (isStartDate) {
            startDateController.text = formattedDateTime;
          } else {
            endDateController.text = formattedDateTime;
          }
        });
      }
    }
  }

  Future<void> _pickStartDate() async {
    FocusScope.of(context).unfocus();

    // Get current start date or use today
    DateTime initialDate;
    try {
      if (startDateController.text.isNotEmpty) {
        initialDate = DateFormat('dd MMM yyyy').parse(startDateController.text);
      } else {
        initialDate = DateTime.now();
      }
    } catch (e) {
      initialDate = DateTime.now();
    }

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      String formattedDate = DateFormat('dd MMM yyyy').format(pickedDate);

      setState(() {
        // Set start date
        startDateController.text = formattedDate;

        // Set end date to the same as start date but not visible in the UI
        // (Only passed to API)
        endDateController.text = formattedDate;
      });
    }
  }

  Future<void> _pickStartTime() async {
    FocusScope.of(context).unfocus();

    // Get current time from startTimeController or use current time
    TimeOfDay initialTime;
    try {
      if (startTimeController.text.isNotEmpty) {
        final parsedTime =
            DateFormat('hh:mm a').parse(startTimeController.text);
        initialTime =
            TimeOfDay(hour: parsedTime.hour, minute: parsedTime.minute);
      } else {
        initialTime = TimeOfDay.now();
      }
    } catch (e) {
      initialTime = TimeOfDay.now();
    }

    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (pickedTime != null) {
      // Create a temporary DateTime to format the time
      final now = DateTime.now();
      final time = DateTime(
          now.year, now.month, now.day, pickedTime.hour, pickedTime.minute);
      String formattedTime = DateFormat('hh:mm a').format(time);

      // Calculate end time (1 hour later)
      final endHour = (pickedTime.hour + 1) % 24;
      final endTime =
          DateTime(now.year, now.month, now.day, endHour, pickedTime.minute);
      String formattedEndTime = DateFormat('hh:mm a').format(endTime);

      setState(() {
        // Set start time
        startTimeController.text = formattedTime;

        // Set end time to 1 hour later but not visible in the UI
        // (Only passed to API)
        endTimeController.text = formattedEndTime;
      });
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.fontBlack,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: AppColors.containerBg,
          ),
          child: Row(
            children: [
              // Expanded TextField that adjusts height
              Expanded(
                child: TextField(
                  controller: controller,
                  maxLines:
                      null, // This allows the TextField to expand vertically based on content
                  minLines: 1, // Minimum 1 line of height
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    border: InputBorder.none,
                  ),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
              // Microphone icon with speech recognition
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () => _toggleListening(controller),
                  icon: Icon(
                    _isListening
                        ? FontAwesomeIcons.stop
                        : FontAwesomeIcons.microphone,
                    color: _isListening ? Colors.red : AppColors.fontColor,
                    size: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Create Test Drive',
                style: GoogleFonts.poppins(
                    fontSize: 20, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchField(),
              // const SizedBox(
              //   height: 10,
              // ),
              _buildSearchField1(),
              const SizedBox(height: 20),
              // Row(
              //   children: [
              //     Expanded(
              //       child: _buildDatePicker(
              //         label: 'Start Date',
              //         controller: startDateController,
              //         onTap: () => _pickDate(isStartDate: true),
              //       ),
              //     ),
              //     const SizedBox(
              //         width: 10), // Space between the two date pickers
              //     Expanded(
              //       child: _buildDatePicker1(
              //         controller: startTimeController,
              //         onTap: _pickStartTime,
              //       ),
              //     ),
              //     // Expanded(
              //     //   child: _buildDatePicker(
              //     //     label: 'End Date',
              //     //     controller: endDateController,
              //     //     onTap: () => _pickDate(isStartDate: false),
              //     //   ),
              //     // ),
              //   ],
              // ),
              Row(
                children: [
                  Text(
                    'Start',
                    style: AppFont.dropDowmLabel(context),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: _buildDatePicker(
                      controller: startDateController,
                      onTap: _pickStartDate,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildDatePicker1(
                      controller: startTimeController,
                      onTap: _pickStartTime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildAssigneSearch(),
              const SizedBox(height: 10),
              _buildTextField(
                  label: 'Comments:',
                  controller: descriptionController,
                  hint: 'Add Comments'),
              const SizedBox(height: 10),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color.fromRGBO(217, 217, 217, 1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5))),
                    onPressed: () => Navigator.pop(context),
                    child: Text("Cancel", style: AppFont.buttons(context))),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.colorsBlueButton,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5))),
                  onPressed: submitForm,
                  child: Text("Create", style: AppFont.buttons(context)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text('Select Vehicle', style: AppFont.dropDowmLabel(context)),
        const SizedBox(height: 10),
        Container(
          height: MediaQuery.of(context).size.height * 0.055,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: AppColors.containerBg,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController1,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.containerBg,
                    hintText: selectedVehicleName ?? 'Select',
                    hintStyle: TextStyle(
                      color: selectedVehicleName != null
                          ? Colors.black
                          : Colors.grey,
                    ),
                    prefixIcon: const Icon(
                      FontAwesomeIcons.magnifyingGlass,
                      size: 15,
                      color: AppColors.iconGrey,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(
                        FontAwesomeIcons.microphone,
                        color: AppColors.iconGrey,
                        size: 15,
                      ),
                      onPressed: () {
                        print('Microphone button pressed');
                      },
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Show loading indicator
        if (_isLoadingSearch1)
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Center(child: CircularProgressIndicator()),
          ),

        // Show search results
        if (_searchResults1.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              boxShadow: const [
                BoxShadow(color: AppColors.iconGrey, blurRadius: 4)
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _searchResults1.length,
              itemBuilder: (context, index) {
                final result1 = _searchResults1[index];
                return ListTile(
                  onTap: () {
                    setState(() {
                      FocusScope.of(context).unfocus();
                      selectedVehicleName =
                          result1['vehicle_name']; // Ensure this is not null
                      _searchController1.clear();
                      _searchResults1.clear();
                    });

                    // ✅ Call the color-fetching function here!
                    if (selectedVehicleName != null) {
                      fetchVehicleColors(
                          selectedVehicleName!); // Ensure vehicleName is not null
                    }
                  },
                  title: Text(
                    result1['vehicle_name'] ?? 'No Name',
                    style: TextStyle(
                      color: selectedVehicleName == result1['vehicle_name']
                          ? Colors.black
                          : AppColors.fontBlack,
                    ),
                  ),
                  leading: const Icon(Icons.directions_car),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildSearchField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Lead', style: AppFont.dropDowmLabel(context)),
        const SizedBox(height: 10),
        Container(
          height: MediaQuery.of(context).size.height * 0.055,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: AppColors.containerBg,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  maxLines: null,
                  minLines: 1,
                  controller: _searchController,
                  decoration: InputDecoration(
                    filled: true,
                    contentPadding: EdgeInsets.zero,
                    fillColor: AppColors.containerBg,
                    hintText: selectedLeadsName ?? 'Select',
                    hintStyle: TextStyle(
                      color: selectedLeadsName != null
                          ? Colors.black
                          : Colors.grey,
                    ),
                    prefixIcon: const Icon(
                      FontAwesomeIcons.magnifyingGlass,
                      size: 15,
                      color: AppColors.iconGrey,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(
                        FontAwesomeIcons.microphone,
                        color: AppColors.iconGrey,
                        size: 15,
                      ),
                      onPressed: () {
                        print('Microphone button pressed');
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Show loading indicator
        if (_isLoadingSearch)
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Center(child: CircularProgressIndicator()),
          ),

        // Show search results
        if (_searchResults.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 4)
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final result = _searchResults[index];
                return ListTile(
                  onTap: () {
                    setState(() {
                      FocusScope.of(context).unfocus();
                      selectedLeads = result['lead_id'];
                      selectedLeadsName = result['lead_name'];
                      _searchController.clear();
                      _searchResults.clear();
                    });
                  },
                  title: Text(
                    result['lead_name'] ?? 'No Name',
                    style: TextStyle(
                      color: selectedLeads == result['lead_id']
                          ? Colors.black
                          : AppColors.fontBlack,
                    ),
                  ),
                  leading: const Icon(Icons.person),
                );
              },
            ),
          ),
      ],
    );
  }

  // Widget _buildSearchField() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text('Choose Lead', style: AppFont.dropDowmLabel(context)),
  //       const SizedBox(height: 5),
  //       SizedBox(
  //         height: MediaQuery.of(context).size.height * .05,
  //         child: TextField(
  //           controller: _searchController,
  //           onTap: () => FocusScope.of(context).unfocus(),
  //           decoration: InputDecoration(
  //             filled: true,
  //             alignLabelWithHint: true,
  //             fillColor: AppColors.containerBg,
  //             hintText: selectedLeadsName ?? 'Select New Leads',
  //             hintStyle: AppFont.dropDown(context),
  //             prefixIcon:
  //                 const Icon(FontAwesomeIcons.magnifyingGlass, size: 15),
  //             border: OutlineInputBorder(
  //                 borderRadius: BorderRadius.circular(5),
  //                 borderSide: BorderSide.none),
  //           ),
  //         ),
  //       ),
  //       if (_isLoadingSearch) const Center(child: CircularProgressIndicator()),
  //       if (_searchResults.isNotEmpty)
  //         Positioned(
  //           top: 50,
  //           left: 20,
  //           right: 20,
  //           child: Material(
  //             elevation: 5,
  //             child: Container(
  //               height: MediaQuery.of(context).size.height * .2,
  //               // margin: const EdgeInsets.only(top: 5),
  //               decoration: BoxDecoration(
  //                   color: Colors.white,
  //                   borderRadius: BorderRadius.circular(5)),
  //               child: ListView.builder(
  //                 itemCount: _searchResults.length,
  //                 itemBuilder: (context, index) {
  //                   final result = _searchResults[index];
  //                   return ListTile(
  //                     onTap: () {
  //                       setState(() {
  //                         FocusScope.of(context).unfocus();
  //                         selectedLeads = result['lead_id'];
  //                         selectedLeadsName = result['lead_name'];
  //                         _searchController.clear();
  //                         _searchResults.clear();
  //                       });
  //                     },
  //                     title: Text(result['lead_name'] ?? 'No Name',
  //                         style: const TextStyle(
  //                           color: AppColors.fontBlack,
  //                         )),
  //                     // subtitle: Text(result['email'] ?? 'No Email'),
  //                     leading: const Icon(Icons.person),
  //                   );
  //                 },
  //               ),
  //             ),
  //           ),
  //         ),
  //     ],
  //   );
  // }

  Widget _buildDatePicker({
    required TextEditingController controller,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 45,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: const Color.fromARGB(255, 248, 247, 247),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    controller.text.isEmpty ? "Select" : controller.text,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color:
                          controller.text.isEmpty ? Colors.grey : Colors.black,
                    ),
                  ),
                ),
                const Icon(
                  Icons.calendar_month_outlined,
                  color: AppColors.iconGrey,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAssigneSearch() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Assignee', style: AppFont.dropDowmLabel(context)),
        const SizedBox(height: 10),
        Container(
          height: MediaQuery.of(context).size.height * 0.055,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: AppColors.containerBg,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchControllerAssignee,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.containerBg,
                    hintText: selectedAssigneName ?? 'Select Assignee',
                    hintStyle: TextStyle(
                      color: selectedAssigneName != null
                          ? Colors.black
                          : Colors.grey,
                    ),
                    prefixIcon: const Icon(
                      FontAwesomeIcons.magnifyingGlass,
                      size: 15,
                      color: AppColors.fontColor,
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                  onTap: () {
                    // If there is a selected lead, populate the text field with its name
                    if (selectedAssigneName != null &&
                        _searchControllerAssignee.text.isEmpty) {
                      _searchControllerAssignee.text = selectedAssigneName!;
                      _searchControllerAssignee.selection =
                          TextSelection.fromPosition(
                        TextPosition(
                            offset: _searchControllerAssignee.text.length),
                      );
                    }
                  },
                  onChanged: (value) {
                    print("TextField onChanged: '$value'"); // Additional debug
                  },
                ),
              ),
            ],
          ),
        ),

        // Show loading indicator
        if (_isLoadingAssignee)
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Center(child: CircularProgressIndicator()),
          ),

        // Show search results
        if (_searchResultsAssignee.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 4)
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _searchResultsAssignee.length,
              itemBuilder: (context, index) {
                final result = _searchResultsAssignee[index];
                return ListTile(
                  onTap: () {
                    setState(() {
                      FocusScope.of(context).unfocus();
                      spId = result['user_id'];
                      selectedAssigne = result['user_id'];
                      selectedAssigneName = result['name'];
                      selectedAssigneEmail = result['email'];

                      _searchControllerAssignee.clear();
                      _searchResultsAssignee.clear();
                    });
                  },
                  title: Text(
                    result['name'] ?? 'No Name',
                    style: GoogleFonts.poppins(
                      color: selectedAssigne == result['user_id']
                          ? Colors.black
                          : AppColors.fontBlack,
                    ),
                  ),
                  subtitle: Text(
                    result['email'] ?? 'No Email',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: selectedAssigne == result['user_id']
                          ? Colors.black
                          : AppColors.fontBlack,
                    ),
                  ),
                  leading: const Icon(Icons.person),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildDatePicker1({
    required TextEditingController controller,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 45,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: const Color.fromARGB(255, 248, 247, 247),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    controller.text.isEmpty ? "Select" : controller.text,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color:
                          controller.text.isEmpty ? Colors.grey : Colors.black,
                    ),
                  ),
                ),
                const Icon(
                  Icons.watch_later_outlined,
                  color: AppColors.iconGrey,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> submitForm() async {
    // Retrieve sp_id from SharedPreferences.
    final prefs = await SharedPreferences.getInstance();
    // final spId = prefs.getString('user_id');

    // Use the lead id from the dropdown selection.
    if (selectedLeads == null) {
      showErrorMessage(context, message: 'Please select a lead.');
      return;
    }
    final leadId = selectedLeads!;

    // Parse and format the selected dates/times.
    final rawStartDate =
        DateFormat('dd MMM yyyy').parse(startDateController.text);
    final rawEndDate = DateFormat('dd MMM yyyy')
        .parse(endDateController.text); // Automatically set

    final rawStartTime = DateFormat('hh:mm a').parse(startTimeController.text);
    final rawEndTime = DateFormat('hh:mm a')
        .parse(endTimeController.text); // Automatically set

    // Format for API
    final formattedStartDate = DateFormat('dd/MM/yyyy').format(rawStartDate);
    final formattedEndDate =
        DateFormat('dd/MM/yyyy').format(rawEndDate); // Automatically set

    final formattedStartTime = DateFormat('HH:mm:ss').format(rawStartTime);
    final formattedEndTime =
        DateFormat('HH:mm:ss').format(rawEndTime); // Automatically set

    if (spId == null || leadId.isEmpty) {
      showErrorMessage(context,
          message: 'User ID or Lead ID not found. Please log in again.');
      return;
    }

    // Prepare the appointment data.
    final testdriveData = {
      'start_date': formattedStartDate,
      'end_date': formattedEndDate,
      'start_time': formattedStartTime,
      'end_time': formattedEndTime,
      'PMI': selectedVehicleName,
      'sp_id': spId,
      'assignee': selectedAssigne,
      'comments': descriptionController.text,
    };

    // Call the service to submit the appointment.
    final success = await LeadsSrv.submitTestDrive(testdriveData, leadId);

    if (success) {
      if (context.mounted) {
        Navigator.pop(context, true); // Close the modal on success.
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Form Submit Successful.')),
      );
      widget.onFormSubmit();
    } else {
      showErrorMessage(context, message: 'Failed to submit appointment.');
    }
  }
}
