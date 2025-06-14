// MiNo App JavaScript

// Configuration
const API_URL = 'http://192.168.0.250:4566/restapis/{API_ID}/dev/_user_request_/'; // Replace {API_ID} with actual API ID after deployment
let currentUser = null;
let userToken = null;
let notes = [];
let currentNoteId = null;

// DOM Elements
const authContainer = document.getElementById('auth-container');
const notesContainer = document.getElementById('notes-container');
const noteEditor = document.getElementById('note-editor');
const authActions = document.getElementById('auth-actions');
const loginTab = document.getElementById('login-tab');
const registerTab = document.getElementById('register-tab');
const loginForm = document.getElementById('login-form');
const registerForm = document.getElementById('register-form');
const notesGrid = document.getElementById('notes-grid');
const emptyState = document.getElementById('empty-state');
const newNoteBtn = document.getElementById('new-note-btn');
const noteForm = document.getElementById('note-form');
const noteTitle = document.getElementById('note-title');
const noteContent = document.getElementById('note-content');
const noteIdField = document.getElementById('note-id');
const closeEditor = document.getElementById('close-editor');
const cancelNote = document.getElementById('cancel-note');
const editorTitle = document.getElementById('editor-title');
const toast = document.getElementById('toast');
const toastMessage = document.getElementById('toast-message');

// Initialize App
function initApp() {
    // Check for stored token
    userToken = localStorage.getItem('token');
    
    if (userToken) {
        // Try to validate token and get user data
        fetchUserData();
    } else {
        // Show auth forms
        showAuthForms();
    }
    
    // Setup event listeners
    setupEventListeners();
}

// Setup Event Listeners
function setupEventListeners() {
    // Auth tabs
    loginTab.addEventListener('click', () => switchAuthTab('login'));
    registerTab.addEventListener('click', () => switchAuthTab('register'));
    
    // Forms
    loginForm.addEventListener('submit', handleLogin);
    registerForm.addEventListener('submit', handleRegister);
    noteForm.addEventListener('submit', handleSaveNote);
    
    // Note buttons
    newNoteBtn.addEventListener('click', showNoteEditor);
    document.querySelectorAll('.new-note-btn').forEach(btn => {
        btn.addEventListener('click', showNoteEditor);
    });
    
    // Close buttons
    closeEditor.addEventListener('click', hideNoteEditor);
    cancelNote.addEventListener('click', hideNoteEditor);
}

// Switch between auth tabs
function switchAuthTab(tab) {
    if (tab === 'login') {
        loginTab.classList.add('text-white', 'bg-gray-700');
        loginTab.classList.remove('text-gray-400');
        registerTab.classList.add('text-gray-400');
        registerTab.classList.remove('text-white', 'bg-gray-700');
        loginForm.classList.remove('hidden');
        registerForm.classList.add('hidden');
    } else {
        registerTab.classList.add('text-white', 'bg-gray-700');
        registerTab.classList.remove('text-gray-400');
        loginTab.classList.add('text-gray-400');
        loginTab.classList.remove('text-white', 'bg-gray-700');
        registerForm.classList.remove('hidden');
        loginForm.classList.add('hidden');
    }
}

// Show auth forms
function showAuthForms() {
    authContainer.classList.remove('hidden');
    notesContainer.classList.add('hidden');
    updateAuthActions(false);
}

// Show notes section
function showNotesSection() {
    authContainer.classList.add('hidden');
    notesContainer.classList.remove('hidden');
    updateAuthActions(true);
    fetchNotes();
}

// Update auth actions in header
function updateAuthActions(isLoggedIn) {
    if (isLoggedIn && currentUser) {
        authActions.innerHTML = `
            <div class="flex items-center">
                <span class="text-gray-400 mr-4">${currentUser.email}</span>
                <button id="logout-btn" class="text-white hover:text-gray-300 transition-colors">
                    <i class="fas fa-sign-out-alt mr-1"></i> Logout
                </button>
            </div>
        `;
        document.getElementById('logout-btn').addEventListener('click', handleLogout);
    } else {
        authActions.innerHTML = `
            <button id="show-auth-btn" class="bg-gray-700 hover:bg-gray-600 text-white px-4 py-2 rounded-lg transition-colors">
                <i class="fas fa-sign-in-alt mr-1"></i> Login / Register
            </button>
        `;
        document.getElementById('show-auth-btn').addEventListener('click', showAuthForms);
    }
}

// Handle login form submission
async function handleLogin(e) {
    e.preventDefault();
    
    const email = document.getElementById('login-email').value;
    const password = document.getElementById('login-password').value;
    
    try {
        const response = await fetch(`${API_URL}auth`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ email, password })
        });
        
        const data = await response.json();
        
        if (response.ok) {
            userToken = data.token;
            currentUser = data.user;
            
            // Save token to localStorage
            localStorage.setItem('token', userToken);
            
            showToast('Logged in successfully');
            showNotesSection();
        } else {
            showToast(data.message || 'Login failed');
        }
    } catch (error) {
        console.error('Login error:', error);
        showToast('Login failed. Please try again.');
    }
}

// Handle register form submission
async function handleRegister(e) {
    e.preventDefault();
    
    const email = document.getElementById('register-email').value;
    const password = document.getElementById('register-password').value;
    const confirmPassword = document.getElementById('register-confirm-password').value;
    
    if (password !== confirmPassword) {
        showToast('Passwords do not match');
        return;
    }
    
    try {
        const response = await fetch(`${API_URL}register`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ email, password })
        });
        
        const data = await response.json();
        
        if (response.ok) {
            showToast('Registration successful! You can now log in.');
            switchAuthTab('login');
            document.getElementById('login-email').value = email;
        } else {
            showToast(data.message || 'Registration failed');
        }
    } catch (error) {
        console.error('Registration error:', error);
        showToast('Registration failed. Please try again.');
    }
}

// Handle logout
function handleLogout() {
    userToken = null;
    currentUser = null;
    notes = [];
    localStorage.removeItem('token');
    showToast('Logged out successfully');
    showAuthForms();
}

// Fetch user data using token
async function fetchUserData() {
    try {
        // Here in a real app we would validate the token with the server
        // For now, we'll just parse the token to get the user data
        
        const tokenParts = userToken.split('.');
        if (tokenParts.length === 3) {
            const payload = JSON.parse(atob(tokenParts[1]));
            
            // Create a simplified user object from token data
            currentUser = {
                userId: payload.userId,
                email: payload.email
            };
            
            showNotesSection();
        } else {
            // Invalid token format
            handleLogout();
        }
    } catch (error) {
        console.error('Token validation error:', error);
        handleLogout();
    }
}

// Fetch notes from API
async function fetchNotes() {
    if (!userToken) return;
    
    try {
        const response = await fetch(`${API_URL}notes`, {
            headers: {
                'Authorization': `Bearer ${userToken}`
            }
        });
        
        const data = await response.json();
        
        if (response.ok && data.success) {
            notes = data.data || [];
            renderNotes();
        } else {
            showToast(data.message || 'Failed to fetch notes');
        }
    } catch (error) {
        console.error('Fetch notes error:', error);
        showToast('Failed to fetch notes');
    }
}

// Render notes in grid
function renderNotes() {
    if (notes.length === 0) {
        notesGrid.classList.add('hidden');
        emptyState.classList.remove('hidden');
        return;
    }
    
    notesGrid.classList.remove('hidden');
    emptyState.classList.add('hidden');
    
    notesGrid.innerHTML = notes.map(note => `
        <div class="note-card bg-gray-800 rounded-lg border border-gray-700 p-4 shadow-md overflow-hidden">
            <h3 class="text-lg font-medium mb-2 text-white">${escapeHtml(note.title)}</h3>
            <p class="text-gray-400 text-sm mb-4 note-content">${escapeHtml(note.content)}</p>
            <div class="flex justify-between items-center border-t border-gray-700 pt-3">
                <span class="text-gray-500 text-xs">${formatDate(note.updatedAt)}</span>
                <div class="note-actions flex gap-2">
                    <button class="edit-note text-gray-400 hover:text-white" data-id="${note.noteId}">
                        <i class="fas fa-edit"></i>
                    </button>
                    <button class="delete-note text-gray-400 hover:text-red-400" data-id="${note.noteId}">
                        <i class="fas fa-trash-alt"></i>
                    </button>
                </div>
            </div>
        </div>
    `).join('');
    
    // Add event listeners to edit/delete buttons
    document.querySelectorAll('.edit-note').forEach(btn => {
        btn.addEventListener('click', () => editNote(btn.dataset.id));
    });
    
    document.querySelectorAll('.delete-note').forEach(btn => {
        btn.addEventListener('click', () => deleteNote(btn.dataset.id));
    });
}

// Show note editor for creating new note
function showNoteEditor(noteId = null) {
    currentNoteId = noteId;
    
    if (noteId) {
        // Edit existing note
        const note = notes.find(n => n.noteId === noteId);
        if (!note) return;
        
        noteTitle.value = note.title;
        noteContent.value = note.content;
        noteIdField.value = note.noteId;
        editorTitle.textContent = 'Edit Note';
    } else {
        // Create new note
        noteForm.reset();
        noteIdField.value = '';
        editorTitle.textContent = 'Create Note';
    }
    
    noteEditor.classList.remove('hidden');
}

// Hide note editor
function hideNoteEditor() {
    noteEditor.classList.add('hidden');
    currentNoteId = null;
}

// Edit note
function editNote(noteId) {
    showNoteEditor(noteId);
}

// Delete note
async function deleteNote(noteId) {
    if (!confirm('Are you sure you want to delete this note?')) {
        return;
    }
    
    try {
        const response = await fetch(`${API_URL}notes/${noteId}`, {
            method: 'DELETE',
            headers: {
                'Authorization': `Bearer ${userToken}`
            }
        });
        
        const data = await response.json();
        
        if (response.ok && data.success) {
            notes = notes.filter(note => note.noteId !== noteId);
            renderNotes();
            showToast('Note deleted successfully');
        } else {
            showToast(data.message || 'Failed to delete note');
        }
    } catch (error) {
        console.error('Delete note error:', error);
        showToast('Failed to delete note');
    }
}

// Handle save note
async function handleSaveNote(e) {
    e.preventDefault();
    
    const title = noteTitle.value;
    const content = noteContent.value;
    const noteId = noteIdField.value;
    
    const isNewNote = !noteId;
    
    try {
        let url = `${API_URL}notes`;
        let method = 'POST';
        
        if (!isNewNote) {
            url = `${API_URL}notes/${noteId}`;
            method = 'PUT';
        }
        
        const response = await fetch(url, {
            method,
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${userToken}`
            },
            body: JSON.stringify({ title, content })
        });
        
        const data = await response.json();
        
        if (response.ok && data.success) {
            if (isNewNote) {
                notes.push(data.data);
            } else {
                const index = notes.findIndex(note => note.noteId === noteId);
                if (index !== -1) {
                    notes[index] = data.data;
                }
            }
            
            renderNotes();
            hideNoteEditor();
            showToast(isNewNote ? 'Note created successfully' : 'Note updated successfully');
        } else {
            showToast(data.message || 'Failed to save note');
        }
    } catch (error) {
        console.error('Save note error:', error);
        showToast('Failed to save note');
    }
}

// Show toast notification
function showToast(message) {
    toastMessage.textContent = message;
    toast.classList.remove('hidden');
    toast.classList.add('toast-show');
    
    setTimeout(() => {
        toast.classList.remove('toast-show');
        toast.classList.add('hidden');
    }, 3000);
}

// Helper function to format date
function formatDate(dateString) {
    const date = new Date(dateString);
    return date.toLocaleDateString() + ' ' + date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
}

// Helper function to escape HTML (prevent XSS)
function escapeHtml(str) {
    if (!str) return '';
    return str
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#039;');
}

// Initialize app when DOM is loaded
document.addEventListener('DOMContentLoaded', initApp);