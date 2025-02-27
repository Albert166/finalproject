from flask import Flask, render_template, request, redirect, url_for, session
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import create_engine
import pymysql
from werkzeug.security import generate_password_hash, check_password_hash
from werkzeug.middleware.proxy_fix import ProxyFix



pymysql.install_as_MySQLdb()

# App Configuration
app = Flask(__name__)
app.wsgi_app = ProxyFix(
    app.wsgi_app, x_for=1, x_host=1, x_port=1, x_proto=1, x_prefix=1
)
app.config['SECRET_KEY'] = 'your-secret-key'  
app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql://user:password@db:3306/shopping_list'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)

# Define admin password
admin_password = generate_password_hash('admin')

# Association table for family members
family_members = db.Table('family_members',
    db.Column('user_id', db.Integer, db.ForeignKey('user.id'), primary_key=True),
    db.Column('family_id', db.Integer, db.ForeignKey('family.id'), primary_key=True)
)

class User(db.Model):
    __tablename__ = 'user'
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    password = db.Column(db.String(255), nullable=False)
    families = db.relationship('Family', backref='owner', lazy=True)
    member_of = db.relationship('Family', secondary=family_members, backref='members', lazy=True)
    shopping_lists = db.relationship('ShoppingList', backref='creator', lazy=True)

class Family(db.Model):
    __tablename__ = 'family'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(80), nullable=False)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    shopping_lists = db.relationship('ShoppingList', backref='family', lazy=True, cascade='all, delete-orphan')

class ShoppingList(db.Model):
    __tablename__ = 'shopping_list'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(80), nullable=False)
    family_id = db.Column(db.Integer, db.ForeignKey('family.id'), nullable=False)
    creator_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    items = db.relationship('ShoppingItem', backref='shopping_list', lazy=True, cascade='all, delete-orphan')

class ShoppingItem(db.Model):
    __tablename__ = 'shopping_item'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(80), nullable=False)
    quantity = db.Column(db.Float, default=1.0)
    completed = db.Column(db.Boolean, default=False)
    measuring_units = db.Column(db.String(80))
    shopping_list_id = db.Column(db.Integer, db.ForeignKey('shopping_list.id'), nullable=False)

# Home page
@app.route('/')
def home():
    if 'user_id' not in session:
        return redirect(url_for('login'))
    user = User.query.get(session['user_id'])
    if user is None:
        # Handle case where user ID in session doesn't exist
        session.pop('user_id', None)
        return redirect(url_for('login'))
    owned_families = Family.query.filter_by(user_id=session['user_id']).all()
    member_families = user.member_of
    return render_template('home.html', 
                           owned_families=owned_families,
                            member_families=member_families,
                             username=user.username)

# Login page
@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        user = User.query.filter_by(username=username).first()

        if user is None:
            return render_template('login.html', error="Username does not exist")
            
        if not check_password_hash(user.password, password):
            return render_template('login.html', error="Incorrect password")
            
        session['user_id'] = user.id
        return redirect(url_for('home'))
        
    return render_template('login.html')

# Register page
@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        
        # Check if username already exists
        if User.query.filter_by(username=username).first():
            return render_template('register.html', error="Username already exists")
            
        hashed_password = generate_password_hash(password)
        
        new_user = User(username=username, password=hashed_password)
        db.session.add(new_user)
        db.session.commit()
        
        return redirect(url_for('login'))
        
    return render_template('register.html')

# Add create family functionality
@app.route('/add_family', methods=['POST'])
def add_family():
    if 'user_id' not in session:
        return redirect(url_for('login'))
        
    name = request.form['name']
    
    new_family = Family(name=name, user_id=session['user_id'])
    db.session.add(new_family)
    db.session.commit()
    
    return redirect(url_for('home'))


# Delete family functionality
@app.route('/delete_family/<int:family_id>', methods=['POST'])
def delete_family(family_id):
    if 'user_id' not in session:
        return redirect(url_for('login'))

    family = Family.query.get_or_404(family_id)

    # Only allow family owner to delete
    if family.user_id == session['user_id']:
        db.session.delete(family)
        db.session.commit()
        return redirect(url_for('home'))
    else:
        # Return to home if not the owner
        return redirect(url_for('home'))

# Add family member functionality
@app.route('/add_family_member/<int:family_id>', methods=['POST'])
def add_family_member(family_id):
    if 'user_id' not in session:
        return redirect(url_for('login'))
        
    username = request.form['username']
    user = User.query.filter_by(username=username).first()
    family = Family.query.get_or_404(family_id)

    usert = User.query.get(session['user_id'])
    owned_families = Family.query.filter_by(user_id=session['user_id']).all()
    member_families = usert.member_of

    if user is None:
        return render_template('home.html',
                                owned_families=owned_families,
                                  member_families=member_families,
                                    username=usert.username,
                                      error="Username does not exist")

    if user and family.user_id == session['user_id']:
        if user not in family.members:
            family.members.append(user)
            db.session.commit()
            return redirect(url_for('home'))
        elif user in family.members:
            return render_template('home.html',
                                    owned_families=owned_families,
                                      member_families=member_families,
                                        username=usert.username,
                                          error="User is already a member of this family")
    return redirect(url_for('add_family_member'))
    
# Add shopping list functionality
@app.route('/add_shopping_list/<int:family_id>', methods=['POST'])
def add_shopping_list(family_id):
    if 'user_id' not in session:
        return redirect(url_for('login'))
        
    name = request.form['name']
    family = Family.query.get_or_404(family_id)
    
    # Allow both owner and members to add shopping lists
    if family.user_id == session['user_id'] or session['user_id'] in [member.id for member in family.members]:
        new_shopping_list = ShoppingList(
            name=name, 
            family_id=family_id,
            creator_id=session['user_id']
        )
        db.session.add(new_shopping_list)
        db.session.commit()
    
    return redirect(url_for('home'))


# Delete shopping list functionality
@app.route('/delete_shopping_list/<int:list_id>', methods=['POST'])
def delete_shopping_list(list_id):
    if 'user_id' not in session:
        return redirect(url_for('login'))
        
    shopping_list = ShoppingList.query.get_or_404(list_id)
    family = Family.query.get(shopping_list.family_id)
    
    # Allow both owner and members to delete shopping lists
    if family.user_id == session['user_id'] or session['user_id'] in [member.id for member in family.members]:
        db.session.delete(shopping_list)
        db.session.commit()
    
    return redirect(url_for('home'))

# Add shopping item functionality
@app.route('/add_shopping_item/<int:list_id>', methods=['POST'])
def add_shopping_item(list_id):
    if 'user_id' not in session:
        return redirect(url_for('login'))
        
    name = request.form['name']
    quantity = request.form.get('quantity', 1.0, type=float)
    measuring_units = request.form.get('measuring_units', "kg" , type=str)
    
    shopping_list = ShoppingList.query.get_or_404(list_id)
    family = Family.query.get(shopping_list.family_id)
    
    # Allow both owner and members to add items
    if family.user_id == session['user_id'] or session['user_id'] in [member.id for member in family.members]:
        new_item = ShoppingItem(name=name,
                                 quantity=quantity,
                                   measuring_units=measuring_units,
                                     shopping_list_id=list_id)
        db.session.add(new_item)
        db.session.commit()
    
    return redirect(url_for('home'))

# Toggle item functionality (mark as completed)
@app.route('/toggle_item/<int:item_id>', methods=['POST'])
def toggle_item(item_id):
    if 'user_id' not in session:
        return redirect(url_for('login'))
        
    item = ShoppingItem.query.get_or_404(item_id)
    shopping_list = ShoppingList.query.get(item.shopping_list_id)
    family = Family.query.get(shopping_list.family_id)
    
    # Allow both owner and members to toggle items
    if family.user_id == session['user_id'] or session['user_id'] in [member.id for member in family.members]:
        item.completed = not item.completed
        db.session.commit()
    
    return redirect(url_for('home'))

# Logout functionality
@app.route('/logout')
def logout():
    session.pop('user_id', None)
    return redirect(url_for('login'))


if __name__ == '__main__':
    app.run(host='0.0.0.0')
    