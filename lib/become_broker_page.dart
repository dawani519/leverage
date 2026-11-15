import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nigerian_states_and_lga/nigerian_states_and_lga.dart';

class BecomeBrokerPage extends StatefulWidget {
  @override
  _BecomeBrokerPageState createState() => _BecomeBrokerPageState();
}

class _BecomeBrokerPageState extends State<BecomeBrokerPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _parkNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String? _selectedState;
  String? _selectedLGA;

  List<String> _states = []; // List of states
  List<String> _lgaList = []; // List of LGAs for the selected state

  @override
  void initState() {
    super.initState();
    // Load all states from the package
    _states = NigerianStatesAndLGA.allStates;
    _selectedLGA = 'Select a Local Government Area';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Become a Broker'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // First Name
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(labelText: 'First Name'),
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter your first name';
                  return null;
                },
              ),
              // Middle Name
              TextFormField(
                controller: _middleNameController,
                decoration: InputDecoration(labelText: 'Middle Name'),
              ),
              // Last Name
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(labelText: 'Last Name'),
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter your last name';
                  return null;
                },
              ),
              // Date of Birth
              TextFormField(
                controller: _dobController,
                decoration: InputDecoration(labelText: 'Date of Birth'),
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1950),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _dobController.text = "${pickedDate.toLocal()}".split(' ')[0];
                    });
                  }
                },
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter your date of birth';
                  return null;
                },
              ),
              // Email
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value!.isEmpty || !value.contains('@')) return 'Please enter a valid email';
                  return null;
                },
              ),
              // Phone Number
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone Number'),
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter a phone number';
                  return null;
                },
              ),
              // State Dropdown
              DropdownButtonFormField(
                decoration: InputDecoration(labelText: 'State'),
                value: _selectedState,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedState = newValue;
                    // Load LGAs based on the selected state
                    _lgaList = NigerianStatesAndLGA.getStateLGAs(newValue!);
                    _selectedLGA = null; // Reset the LGA selection
                  });
                },
                items: _states.map((state) {
                  return DropdownMenuItem(
                    child: Text(state),
                    value: state,
                  );
                }).toList(),
                validator: (value) {
                  if (value == null) return 'Please select a state';
                  return null;
                },
              ),
              // LGA Dropdown
              DropdownButtonFormField(
                decoration: InputDecoration(labelText: 'Local Government Area'),
                value: _selectedLGA,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedLGA = newValue;
                  });
                },
                items: _lgaList.map((lga) {
                  return DropdownMenuItem(
                    child: Text(lga),
                    value: lga,
                  );
                }).toList(),
                validator: (value) {
                  if (value == null) return 'Please select an LGA';
                  return null;
                },
              ),
              // Park Name
              TextFormField(
                controller: _parkNameController,
                decoration: InputDecoration(labelText: 'Name of Park'),
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter the name of the park';
                  return null;
                },
              ),


              // Password
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter a password';
                  return null;
                },
              ),
              // Confirm Password
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(labelText: 'Confirm Password'),
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) return 'Please confirm your password';
                  if (value != _passwordController.text) return 'Passwords do not match';
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Register as Broker'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Form submission logic
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Create a user with email and password
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        User? currentUser = userCredential.user; // Get the newly created user

        // Store broker data in Firestore in the 'brokers' collection
        await FirebaseFirestore.instance.collection('brokers').doc(currentUser?.uid).set({
          'firstName': _firstNameController.text,
          'middleName': _middleNameController.text,
          'lastName': _lastNameController.text,
          'dob': _dobController.text,
          'state': _selectedState,
          'lga': _selectedLGA,
          'parkName': _parkNameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
        });

        // Notify user of successful registration
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Broker registration successful')));
        Navigator.pop(context); // Go back to the previous page
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to register broker: $e')));
      }
    }
  }
}
