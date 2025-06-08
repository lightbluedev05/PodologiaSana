import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/colors.dart';
import 'package:table_calendar/table_calendar.dart';


class InicioView extends StatefulWidget {
  const InicioView({super.key});

  @override
  State<InicioView> createState() => _InicioViewState();
}

class _InicioViewState extends State<InicioView> {
  String _calendarView = 'Día';
  DateTime _selectedDate = DateTime.now();

  final List<Map<String, String>> citas = [
    {'paciente': 'Ana Torres', 'hora': '10:00 AM', 'tipo': 'Evaluación'},
    {'paciente': 'Luis Pérez', 'hora': '11:30 AM', 'tipo': 'Tratamiento'},
    {'paciente': 'Claudia Rivas', 'hora': '01:00 PM', 'tipo': 'Control'},
  ];

  final List<String> pacientesRecientes = [
    'Marta Soto',
    'Javier Luna',
    'Carmen Ruiz',
  ];

  final Map<String, int> estadisticas = {
    'Citas Hoy': 6,
    'Citas Semana': 18,
    'Pacientes Nuevos': 4,
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                //child: _buildCalendario(),
                child: SizedBox(
                  height: 500,
                  child: _buildCalendario(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _buildProximasCitas(),
                    const SizedBox(height: 16),
                    _buildPacientesRecientes(),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildEstadisticas(),
        ],
      ),
    );
  }

  Widget _buildCalendario() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.azulClaro,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                'Calendario - Vista $_calendarView',
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              ToggleButtons(
                isSelected: [
                  _calendarView == 'Día',
                  _calendarView == 'Semana',
                  _calendarView == 'Mes'
                ],
                onPressed: (index) {
                  setState(() {
                    _calendarView = ['Día', 'Semana', 'Mes'][index];
                  });
                },
                children: const [
                  Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Día')),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Semana')),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Mes')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _selectedDate,
            selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
            calendarFormat: _calendarView == 'Día'
                ? CalendarFormat.values[0]
                : _calendarView == 'Semana'
                ? CalendarFormat.week
                : CalendarFormat.month,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDate = selectedDay;
              });
            },
            calendarStyle: const CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.orangeAccent,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildProximasCitas() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.celesteSuave,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Próximas Citas',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          for (var cita in citas)
            ListTile(
              title: Text(cita['paciente']!),
              subtitle: Text('${cita['hora']} - ${cita['tipo']}'),
              leading: const Icon(Icons.event_available),
            )
        ],
      ),
    );
  }

  Widget _buildPacientesRecientes() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.lilaPastel,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pacientes Recientes',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          for (var paciente in pacientesRecientes)
            ListTile(
              title: Text(paciente),
              leading: const Icon(Icons.person),
            )
        ],
      ),
    );
  }

  Widget _buildEstadisticas() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: estadisticas.entries.map((e) {
        return Expanded(
          child: Card(
            color: AppColors.azulMedio,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    e.key,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    e.value.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
