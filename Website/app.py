# app.py - COMPLETE WITH ALL FUNCTIONS
from flask import Flask, render_template, request, redirect, url_for, session
from database import get_db_connection
from datetime import datetime

app = Flask(__name__)
app.config['SECRET_KEY'] = 'iti-exam-system-secret-key-2024'

def execute_stored_procedure(procedure_name, params=None, fetch=False):
    """Execute stored procedures instead of direct queries"""
    conn = get_db_connection()
    if not conn:
        print(" No database connection in execute_stored_procedure")
        return None
    
    try:
        cursor = conn.cursor()
        
        # Build the stored procedure call
        param_placeholders = ', '.join(['?'] * len(params)) if params else ''
        sql = f"EXEC {procedure_name} {param_placeholders}"
        
        print(f" Executing stored procedure: {sql}")
        print(f" With params: {params}")
        
        if params:
            cursor.execute(sql, params)
        else:
            cursor.execute(sql)
        
        # **DEBUG: Check if we have results**
        if cursor.description:
            print(f" Stored procedure returned columns: {[column[0] for column in cursor.description]}")
        else:
            print(" Stored procedure returned no columns (no result set)")
        
        if fetch:
            # For stored procedures that return data
            if cursor.description:  # Check if there are results
                columns = [column[0] for column in cursor.description]
                results = []
                rows = cursor.fetchall()
                
                
                for row in rows:
                    row_dict = dict(zip(columns, row))
                    results.append(row_dict)
                    
                
                return results
            else:
                
                return None
        else:
            # For procedures that don't return data (INSERT/UPDATE)
            conn.commit()
            return True
            
    except Exception as e:
        print(f" Stored procedure error: {e}")
        import traceback
        print(f" Full error details: {traceback.format_exc()}")
        conn.rollback()
        return None
    finally:
        conn.close()

def execute_query(query, params=None, fetch=False):
    """Execute direct database queries safely"""
    conn = get_db_connection()
    if not conn:
        print(" No database connection")
        return None
    
    try:
        cursor = conn.cursor()
        
        if params:
            cursor.execute(query, params)
        else:
            cursor.execute(query)
        
        if fetch:
            if 'SELECT' in query.upper():
                columns = [column[0] for column in cursor.description]
                results = []
                for row in cursor.fetchall():
                    results.append(dict(zip(columns, row)))
                return results
            return cursor.fetchall()
        else:
            conn.commit()
            return True
            
    except Exception as e:
        print(f" Query error: {e}")
        return None
    finally:
        conn.close()


@app.route('/')
def home():
    return render_template('index.html')

@app.route('/student/login', methods=['GET', 'POST'])
def student_login():
    if request.method == 'POST':
        student_id = request.form.get('student_id', '').strip()
        password = request.form.get('password', '').strip()
        
        if not student_id or not password:
            return render_template('student/login.html', error='Please fill in all fields')
        
        # Using direct query for login (simple check)
        query = "SELECT Student_ID, Student_Name FROM Student WHERE Student_ID = ? AND Password = ?"
        conn = get_db_connection()
        if conn:
            try:
                cursor = conn.cursor()
                cursor.execute(query, (student_id, password))
                columns = [column[0] for column in cursor.description]
                student = cursor.fetchone()
                if student:
                    student_dict = dict(zip(columns, student))
                    session['student_id'] = student_dict['Student_ID']
                    session['user_type'] = 'student'
                    session['student_name'] = student_dict['Student_Name']
                    return redirect(url_for('student_dashboard'))
                else:
                    return render_template('student/login.html', error='Invalid Student ID or password')
            except Exception as e:
                return render_template('student/login.html', error='Login error')
            finally:
                conn.close()
        else:
            return render_template('student/login.html', error='Database connection failed')
    
    return render_template('student/login.html')

@app.route('/instructor/login', methods=['GET', 'POST'])
def instructor_login():
    if request.method == 'POST':
        instructor_id = request.form.get('instructor_id', '').strip()
        password = request.form.get('password', '').strip()
        
        if not instructor_id or not password:
            return render_template('instructor/login.html', error='Please fill in all fields')
        
        # Using direct query for login (simple check)
        query = "SELECT Instructor_ID, Instructor_Name FROM Instructor WHERE Instructor_ID = ? AND Password = ?"
        conn = get_db_connection()
        if conn:
            try:
                cursor = conn.cursor()
                cursor.execute(query, (instructor_id, password))
                columns = [column[0] for column in cursor.description]
                instructor = cursor.fetchone()
                if instructor:
                    instructor_dict = dict(zip(columns, instructor))
                    session['instructor_id'] = instructor_dict['Instructor_ID']
                    session['user_type'] = 'instructor'
                    session['instructor_name'] = instructor_dict['Instructor_Name']
                    return redirect(url_for('instructor_dashboard'))
                else:
                    return render_template('instructor/login.html', error='Invalid Instructor ID or password')
            except Exception as e:
                return render_template('instructor/login.html', error='Login error')
            finally:
                conn.close()
        else:
            return render_template('instructor/login.html', error='Database connection failed')
    
    return render_template('instructor/login.html')

@app.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('home'))


@app.route('/student/dashboard')
def student_dashboard():
    if 'student_id' not in session or session['user_type'] != 'student':
        return redirect(url_for('student_login'))
    
    # Get current date and time
    current_datetime = datetime.now()
    current_date = current_datetime.strftime('%Y-%m-%d')
    current_time = current_datetime.strftime('%H:%M:%S')
    
    print(f"🔍 Current date: {current_date}, Current time: {current_time}")
    
    # Get available exams - ONLY exams that are scheduled for NOW
    available_exams_query = """
    SELECT e.Exam_ID, e.Title, e.Exam_Date, e.Start_Time, e.End_Time, c.Course_Name, e.Total_Marks
    FROM Exams e
    JOIN Course c ON e.Course_ID = c.Course_ID
    WHERE e.Exam_Date = ? 
      AND e.Start_Time <= ? 
      AND e.End_Time >= ?
      AND NOT EXISTS (
        SELECT 1 FROM Student_Exam se 
        WHERE se.Student_ID = ? AND se.Exam_ID = e.Exam_ID
      )
    ORDER BY e.Start_Time
    """
    
    
    available_exams = []
    conn1 = get_db_connection()
    if conn1:
        try:
            cursor = conn1.cursor()
            cursor.execute(available_exams_query, (current_date, current_time, current_time, session['student_id']))
            columns = [column[0] for column in cursor.description]
            for row in cursor.fetchall():
                available_exams.append(dict(zip(columns, row)))
            print(f"🔍 Found {len(available_exams)} available exams for current time")
        except Exception as e:
            print(f"Error getting available exams: {e}")
        finally:
            conn1.close()
    
    # Get completed exams
    completed_exams_query = """
    SELECT se.Exam_ID, e.Title as Exam_Title, se.Student_Score, e.Total_Marks,
           c.Course_Name, se.Exam_Status
    FROM Student_Exam se
    JOIN Exams e ON se.Exam_ID = e.Exam_ID
    JOIN Course c ON e.Course_ID = c.Course_ID
    WHERE se.Student_ID = ?
    """
    completed_exams = []
    conn2 = get_db_connection()
    if conn2:
        try:
            cursor = conn2.cursor()
            cursor.execute(completed_exams_query, (session['student_id'],))
            columns = [column[0] for column in cursor.description]
            for row in cursor.fetchall():
                completed_exams.append(dict(zip(columns, row)))
        except Exception as e:
            print(f"Error getting completed exams: {e}")
        finally:
            conn2.close()
    
    return render_template('student/dashboard.html',
                         student_name=session['student_name'],
                         grades=completed_exams,
                         available_exams=available_exams,
                         current_time=current_datetime.strftime('%Y-%m-%d %H:%M'))
@app.route('/exam/<int:exam_id>')
def take_exam(exam_id):
    if 'student_id' not in session:
        return redirect(url_for('student_login'))
    
    # Use stored procedure to start exam and get questions
    exam_data = execute_stored_procedure('sp_Start_Exam', [exam_id, session['student_id']], fetch=True)
    
    if not exam_data:
        return "Cannot start exam. It may not be available or you've already taken it."
    
    # Get exam details using stored procedure
    exam_details = execute_stored_procedure('Get_Exam_By_ID', [exam_id], fetch=True)
    
    # Organize questions by question ID
    organized_questions = {}
    for question in exam_data:
        qid = question['Question_ID']
        if qid not in organized_questions:
            organized_questions[qid] = {
                'text': question['Question_Head'],
                'type': question['Question_Type'],
                'choices': []
            }
        organized_questions[qid]['choices'].append({
            'choice_id': question['Choice_ID'],
            'text': question['Choice_Text']
        })
    
    return render_template('student/exam.html', 
                         exam=exam_details[0] if exam_details else {'Title': 'Exam', 'Exam_ID': exam_id},
                         questions=organized_questions,
                         exam_id=exam_id)

@app.route('/submit_exam/<int:exam_id>', methods=['POST'])
def submit_exam(exam_id):
    if 'student_id' not in session:
        return redirect(url_for('student_login'))
    
    student_id = session['student_id']
    answers = request.form
    
    # Workaround: Insert answers directly
    conn = get_db_connection()
    if conn:
        try:
            cursor = conn.cursor()
            
            # First, create student exam record
            cursor.execute("""
                INSERT INTO Student_Exam (Exam_ID, Student_ID, Student_Score, Submission_Time, Exam_Status)
                VALUES (?, ?, 0, GETDATE(), 'Submitted')
            """, (exam_id, student_id))
            
            # Then insert each answer
            for question_id, choice_id in answers.items():
                if question_id.startswith('question_'):
                    qid = question_id.replace('question_', '')
                    cursor.execute("""
                        INSERT INTO Student_Exam_Questions (Student_ID, Exam_ID, Question_ID, Selected_Choice_ID, Ques_Mark)
                        VALUES (?, ?, ?, ?, 0)
                    """, (student_id, exam_id, qid, choice_id))
            
            conn.commit()
            
            # Auto-correct the exam using stored procedure
            execute_stored_procedure('sp_Correct_Exam', [exam_id, student_id])
            
        except Exception as e:
            print(f"Error submitting exam: {e}")
            return "Error submitting exam"
        finally:
            conn.close()
    
    return redirect(url_for('exam_results', exam_id=exam_id))

@app.route('/results/<int:exam_id>')
def exam_results(exam_id):
    if 'student_id' not in session:
        return redirect(url_for('student_login'))
    
    # Get exam results with student answers using stored procedure
    results = execute_stored_procedure('Get_Exam_Questions_With_Student_Answers', 
                                     [exam_id, session['student_id']], fetch=True) or []
    
    # Get exam details
    exam_details = execute_stored_procedure('Get_Exam_By_ID', [exam_id], fetch=True)
    
    # Calculate total score
    total_score = sum(result['Ques_Mark'] for result in results) if results else 0
    
    return render_template('student/results.html', 
                         results=results,
                         exam=exam_details[0] if exam_details else None,
                         total_score=total_score,
                         exam_id=exam_id)


@app.route('/instructor/dashboard')
def instructor_dashboard():
    if 'instructor_id' not in session or session['user_type'] != 'instructor':
        return redirect(url_for('instructor_login'))
    
    # Get instructor courses using stored procedure
    courses = execute_stored_procedure('GetInstructorCoursesWithStudentCount', 
                                     [session['instructor_id']], fetch=True) or []
    
    # Get course IDs for this instructor
    course_names = [course['Course_Name'] for course in courses]
    
    # Get exams only for instructor's courses - SIMPLIFIED
    exams_query = """
    SELECT e.Exam_ID, e.Title, e.Exam_Date, c.Course_Name,
       (SELECT COUNT(*) FROM Student_Exam se WHERE se.Exam_ID = e.Exam_ID) as students_taken, 
       e.Total_Marks
    FROM Exams e
    JOIN Course c ON e.Course_ID = c.Course_ID
    WHERE c.Course_Name IN ({})
    ORDER BY e.Exam_Date DESC
    """.format(','.join(['?'] * len(course_names)))
    
    conn = get_db_connection()
    exams = []
    if conn:
        try:
            cursor = conn.cursor()
            cursor.execute(exams_query, course_names)
            columns = [column[0] for column in cursor.description]
            for row in cursor.fetchall():
                exams.append(dict(zip(columns, row)))
        except Exception as e:
            print(f"Error getting exams: {e}")
        finally:
            conn.close()
    
    return render_template('instructor/dashboard.html',
                         instructor_name=session['instructor_name'],
                         courses=courses,
                         exams=exams)

@app.route('/instructor/create_exam', methods=['GET', 'POST'])
def create_exam():
    if 'instructor_id' not in session:
        return redirect(url_for('instructor_login'))
    
    if request.method == 'POST':
        # Get form data
        course_name = request.form.get('course_name')
        exam_date = request.form.get('exam_date')
        start_time = request.form.get('start_time')
        end_time = request.form.get('end_time')
        no_tf = int(request.form.get('no_tf', 0))
        no_mcq = int(request.form.get('no_mcq', 0))
        
        print(f" Creating exam with: {course_name}, {exam_date}, {start_time}, {end_time}, TF: {no_tf}, MCQ: {no_mcq}")
        
        # **ALTERNATIVE APPROACH: Use direct connection**
        conn = get_db_connection()
        if not conn:
            return render_template('instructor/exam_error.html',
                                 error_message="Database connection failed.")
        
        try:
            cursor = conn.cursor()
            
            # Call stored procedure directly
            sql = "EXEC sp_Generate_Exam ?, ?, ?, ?, ?, ?"
            params = [course_name, exam_date, start_time, end_time, no_tf, no_mcq]
            
            print(f" Direct SQL: {sql}")
            print(f" Direct params: {params}")
            
            cursor.execute(sql, params)
            
            # Check if we got results
            if cursor.description:
                columns = [column[0] for column in cursor.description]
                row = cursor.fetchone()
                
                if row:
                    exam_data = dict(zip(columns, row))
                    print(f"✅ Exam created successfully: {exam_data}")
                    
                    conn.commit()
                    
                    return render_template('instructor/exam_created.html',
                                         exam_id=exam_data['Exam_ID'],
                                         exam_title=exam_data['Exam_Title'],
                                         course_name=exam_data['Course_Name'],
                                         exam_date=exam_data['Exam_Date'],
                                         start_time=exam_data['Start_Time'],
                                         end_time=exam_data['End_Time'],
                                         no_tf=exam_data['No_TF_Questions'],
                                         no_mcq=exam_data['No_MCQ_Questions'],
                                         total_questions=exam_data['Total_Questions'])
                else:
                    conn.rollback()
                    return render_template('instructor/exam_error.html',
                                         error_message="Stored procedure executed but returned no data.")
            else:
                conn.rollback()
                return render_template('instructor/exam_error.html',
                                     error_message="Stored procedure executed but returned no result set.")
            
        except Exception as e:
            conn.rollback()
            print(f" Error in create_exam: {str(e)}")
            
            error_msg = str(e)
            if "Exam date cannot be in the past" in error_msg:
                error_msg = "Exam date cannot be in the past."
            elif "Exam start time cannot be in the past" in error_msg:
                error_msg = "Exam start time cannot be in the past for today's date."
            elif "Exam duration cannot exceed 2 hours" in error_msg:
                error_msg = "Exam duration cannot exceed 2 hours."
            elif "Total number of questions cannot exceed 25" in error_msg:
                error_msg = "Total number of questions cannot exceed 25."
            elif "Course name is invalid" in error_msg:
                error_msg = "Course name is invalid or does not exist."
            else:
                error_msg = f"Database error: {error_msg}"
            
            return render_template('instructor/exam_error.html',
                                 error_message=error_msg)
        finally:
            conn.close()
    
    # GET request - keep your existing code
    courses_query = """
    SELECT DISTINCT c.Course_Name 
    FROM Course c
    INNER JOIN Questions q ON c.Course_ID = q.Course_ID
    WHERE EXISTS (
        SELECT 1 FROM Questions q2 
        WHERE q2.Course_ID = c.Course_ID
    )
    ORDER BY c.Course_Name
    """
    
    conn = get_db_connection()
    courses = []
    if conn:
        try:
            cursor = conn.cursor()
            cursor.execute(courses_query)
            courses = [row[0] for row in cursor.fetchall()]
            print(f" Available courses with questions: {len(courses)} courses")
        except Exception as e:
            print(f"Error getting courses: {e}")
        finally:
            conn.close()
    
    today = datetime.now().strftime('%Y-%m-%d')
    return render_template('instructor/create_exam.html', courses=courses, today=today)
@app.route('/debug/check-exams')
def debug_check_exams():
    """Check all exams in the database"""
    conn = get_db_connection()
    if not conn:
        return "No database connection"
    
    try:
        cursor = conn.cursor()
        
        # Check Exams table
        cursor.execute("SELECT * FROM Exams ORDER BY Exam_ID DESC")
        exams = cursor.fetchall()
        
        # Check Exam_Questions table
        cursor.execute("""
            SELECT eq.Exam_ID, COUNT(eq.Question_ID) as question_count 
            FROM Exam_Questions eq 
            GROUP BY eq.Exam_ID
        """)
        exam_questions = cursor.fetchall()
        
        result = "<h1>Database Exams Debug</h1>"
        
        result += "<h2>Exams Table:</h2>"
        if exams:
            result += f"<p>Found {len(exams)} exams</p>"
            result += "<table border='1'><tr><th>Exam_ID</th><th>Title</th><th>Exam_Date</th><th>Start_Time</th><th>End_Time</th><th>Course_ID</th></tr>"
            for exam in exams:
                result += f"<tr><td>{exam[0]}</td><td>{exam[1]}</td><td>{exam[4]}</td><td>{exam[5]}</td><td>{exam[6]}</td><td>{exam[7]}</td></tr>"
            result += "</table>"
        else:
            result += "<p>No exams found in database</p>"
        
        result += "<h2>Exam Questions:</h2>"
        if exam_questions:
            result += "<table border='1'><tr><th>Exam_ID</th><th>Question Count</th></tr>"
            for eq in exam_questions:
                result += f"<tr><td>{eq[0]}</td><td>{eq[1]}</td></tr>"
            result += "</table>"
        else:
            result += "<p>No exam questions found</p>"
            
        return result
        
    except Exception as e:
        return f"Error: {e}"
    finally:
        conn.close()
@app.route('/debug-db-state')
def debug_db_state():
    """Check current database state"""
    conn = get_db_connection()
    if not conn:
        return "No database connection"
    
    try:
        cursor = conn.cursor()
        
        result = "<h1>Database State Debug</h1>"
        
        # Check max exam ID
        cursor.execute("SELECT ISNULL(MAX(Exam_ID), 0) as max_exam_id FROM Exams")
        max_id = cursor.fetchone()[0]
        result += f"<h2>Current Max Exam ID: {max_id}</h2>"
        
        # Check courses
        cursor.execute("SELECT Course_ID, Course_Name FROM Course")
        courses = cursor.fetchall()
        result += f"<h2>Available Courses ({len(courses)}):</h2>"
        for course in courses:
            result += f"<p>ID: {course[0]}, Name: {course[1]}</p>"
        
        # Check questions count by course and type
        cursor.execute("""
        SELECT c.Course_Name, q.Question_Type, COUNT(*) as question_count
        FROM Questions q
        JOIN Course c ON q.Course_ID = c.Course_ID
        GROUP BY c.Course_Name, q.Question_Type
        ORDER BY c.Course_Name, q.Question_Type
        """)
        questions = cursor.fetchall()
        result += "<h2>Questions by Course and Type:</h2>"
        for question in questions:
            result += f"<p>{question[0]} - {question[1]}: {question[2]} questions</p>"
        
        return result
        
    except Exception as e:
        return f"Error: {e}"
    finally:
        conn.close()
@app.route('/instructor/add_questions/<int:exam_id>', methods=['GET', 'POST'])
def add_questions(exam_id):
    if 'instructor_id' not in session:
        return redirect(url_for('instructor_login'))
    
    if request.method == 'POST':
        question_text = request.form.get('question_text')
        question_type = request.form.get('question_type', 'multiple_choice')
        correct_answer = request.form.get('correct_answer')
        choices = request.form.getlist('choices')
        
        # Insert question using execute_query (now defined)
        question_query = "INSERT INTO Questions (Question_Type, Question_Text, Correct_Answer) VALUES (?, ?, ?)"
        question_result = execute_query(question_query, (question_type, question_text, correct_answer))
        
        if question_result:
            # Get the last inserted question ID
            get_last_id = "SELECT MAX(Question_ID) as last_id FROM Questions"
            last_id_result = execute_query(get_last_id, fetch=True)
            
            if last_id_result and last_id_result[0]['last_id']:
                question_id = last_id_result[0]['last_id']
                
                # Link question to exam
                link_query = "INSERT INTO Exam_Questions (Exam_ID, Question_ID) VALUES (?, ?)"
                execute_query(link_query, (exam_id, question_id))
                
                # Add choices if multiple choice
                if question_type == 'multiple_choice' and choices:
                    for choice in choices:
                        if choice.strip():  # Only add non-empty choices
                            choice_query = "INSERT INTO Question_Choices (Question_ID, Choices) VALUES (?, ?)"
                            execute_query(choice_query, (question_id, choice.strip()))
                
                return redirect(url_for('instructor_dashboard'))
    
    return render_template('instructor/add_questions.html', exam_id=exam_id)

@app.route('/instructor/exam/<int:exam_id>')
def view_exam_results(exam_id):
    if 'instructor_id' not in session:
        return redirect(url_for('instructor_login'))
    
    # Get exam details
    exam_details = execute_stored_procedure('Get_Exam_By_ID', [exam_id], fetch=True)
    
    # Get student results for this exam
    results_query = """
    SELECT se.Student_ID, s.Student_Name, se.Student_Score, e.Total_Marks,
           se.Submission_Time, se.Exam_Status
    FROM Student_Exam se
    JOIN Student s ON se.Student_ID = s.Student_ID
    JOIN Exams e ON se.Exam_ID = e.Exam_ID
    WHERE se.Exam_ID = ?
    ORDER BY se.Student_Score DESC
    """
    conn = get_db_connection()
    results = []
    if conn:
        try:
            cursor = conn.cursor()
            cursor.execute(results_query, (exam_id,))
            columns = [column[0] for column in cursor.description]
            for row in cursor.fetchall():
                results.append(dict(zip(columns, row)))
        except Exception as e:
            print(f"Error getting results: {e}")
        finally:
            conn.close()
    
    return render_template('instructor/exam_results.html',
                         exam=exam_details[0] if exam_details else None,
                         results=results)

@app.route('/branches')
def branches():
    """Branches information page"""
    branches_data = [
        {"name": "Smart Village", "location": "30°04'16.2\"N 31°01'15.7\"E", "year": 2009, "city": "Giza"},
        {"name": "New Capital", "location": "30°01'21.2\"N 31°42'20.7\"E", "year": 2022, "city": "New Administrative Capital"},
        {"name": "Cairo University", "location": "30°01'45.8\"N 31°12'07.1\"E", "year": 2022, "city": "Giza"},
        {"name": "Alexandria", "location": "31°11'34.7\"N 29°54'21.9\"E", "year": 1996, "city": "Alexandria"},
        {"name": "Assiut", "location": "27°11'16.1\"N 31°10'09.7\"E", "year": 2007, "city": "Assiut"},
        {"name": "Aswan", "location": "23°59'56.6\"N 32°51'18.9\"E", "year": 2021, "city": "Aswan"},
        {"name": "Beni Suef", "location": "29°00'33.9\"N 31°09'08.6\"E", "year": 2023, "city": "Beni Suef"},
        {"name": "Fayoum", "location": "29°19'24.1\"N 30°50'17.8\"E", "year": 2024, "city": "Fayoum"},
        {"name": "Ismailia", "location": "30°37'16.2\"N 32°16'07.9\"E", "year": 2013, "city": "Ismailia"},
        {"name": "Mansoura", "location": "31°02'27.9\"N 31°21'16.2\"E", "year": 2007, "city": "Mansoura"},
        {"name": "Menofia", "location": "30°33'29.4\"N 31°01'08.2\"E", "year": 2020, "city": "Menofia"},
        {"name": "Minya", "location": "28°07'40.4\"N 30°43'55.5\"E", "year": 2020, "city": "Minya"},
        {"name": "Qena", "location": "26°11'22.5\"N 32°44'49.3\"E", "year": 2020, "city": "Qena"},
        {"name": "Sohag", "location": "26°27'31.2\"N 31°40'21.2\"E", "year": 2020, "city": "Sohag"},
        {"name": "Tanta", "location": "30°49'34.8\"N 31°00'07.2\"E", "year": 2024, "city": "Tanta"},
        {"name": "Zagazig", "location": "30°35'15.6\"N 31°28'47.1\"E", "year": 2024, "city": "Zagazig"},
        {"name": "New Valley", "location": "25°27'23.2\"N 30°32'55.0\"E", "year": 2023, "city": "New Valley"},
        {"name": "Damanhour", "location": "31°02'15.0\"N 30°25'59.3\"E", "year": 2024, "city": "Damanhour"},
        {"name": "Al Arish", "location": "31°07'57.8\"N 33°49'38.5\"E", "year": 2024, "city": "Al Arish"},
        {"name": "Banha", "location": "30°28'31.6\"N 31°11'55.5\"E", "year": 2024, "city": "Banha"},
        {"name": "Port Said", "location": "31°14'46.7\"N 32°18'50.4\"E", "year": 2024, "city": "Port Said"},
        {"name": "Damietta", "location": "31°30'01.0\"N 31°49'34.2\"E", "year": 2024, "city": "Damietta"}
    ]
    
    return render_template('branches.html', branches=branches_data)


if __name__ == '__main__':
    print("🚀 ITI Exam System Starting...")
    print("📍 Local: http://localhost:5000")
    app.run(debug=True, host='0.0.0.0', port=5000)