import pickle
import requests
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

# --- Universal CORS Authorization ---
# The allow_credentials=False fix is applied here so Chrome lets the posters through!
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  
    allow_credentials=False,  
    allow_methods=["*"],
    allow_headers=["*"],
)
# ------------------------------------

# Load the Machine Learning models
movies = pickle.load(open('models/movie_list.pkl', 'rb'))
similarity = pickle.load(open('models/similarity.pkl', 'rb'))

def fetch_poster(movie_id):
    # Fetch the live movie poster from TMDB
    url = f"https://api.themoviedb.org/3/movie/{movie_id}?api_key=8265bd1679663a7ea12ac168da84d2e8&language=en-US"
    try:
        data = requests.get(url).json()
        return "https://image.tmdb.org/t/p/w500/" + data['poster_path']
    except Exception:
        # Fallback image if the API fails
        return "https://images.unsplash.com/photo-1440404653325-ab127d49abc1?w=500"

@app.get("/recommendations/{movie_title}")
def get_recommendations(movie_title: str):
    try:
        # Find the movie index based on the title (case-insensitive)
        index = movies[movies['title'].str.lower() == movie_title.lower()].index[0]
        distances = sorted(list(enumerate(similarity[index])), reverse=True, key=lambda x: x[1])
        
        recommendations = []
        # Get the top 5 closest matches
        for i in distances[1:6]:
            movie_id = int(movies.iloc[i[0]].movie_id)
            title = str(movies.iloc[i[0]].title)
            poster = fetch_poster(movie_id)
            recommendations.append({"title": title, "poster_url": poster})
            
        return {"status": "success", "data": recommendations}
    except IndexError:
        return {"status": "error", "message": f"Movie '{movie_title}' not found in the database."}