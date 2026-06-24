// app.js
// UI Logic and Data Fetching for Multi-Page Site

document.addEventListener('DOMContentLoaded', () => {
    // Set Current Year in Footer
    const yearEl = document.getElementById('year');
    if (yearEl) yearEl.textContent = new Date().getFullYear();

    // Scroll Progress Logic
    const scrollProgress = document.getElementById('scroll-progress');
    window.addEventListener('scroll', () => {
        const totalScroll = document.documentElement.scrollTop;
        const windowHeight = document.documentElement.scrollHeight - document.documentElement.clientHeight;
        const scroll = windowHeight > 0 ? `${totalScroll / windowHeight * 100}%` : '0%';
        if (scrollProgress) scrollProgress.style.width = scroll;
    });

    // Mobile Menu Toggle
    const hamburger = document.querySelector('.hamburger');
    const navMenu = document.querySelector('.nav-links');
    if (hamburger && navMenu) {
        hamburger.addEventListener('click', () => {
            navMenu.classList.toggle('active');
        });
    }

    // Reveal Animations on Load
    const reveals = document.querySelectorAll('.reveal-up');
    reveals.forEach((el, index) => {
        setTimeout(() => {
            el.classList.add('active');
        }, 100 * index); // Staggered delay
    });

    // GitHub Data Fetching (Only runs if container exists on the page)
    const container = document.getElementById('github-container');
    if (container) {
        const fetchGitHubData = async () => {
            const username = 'PadeepRathi';
            try {
                const response = await fetch(`https://api.github.com/users/${username}/repos?sort=updated&per_page=4`);
                if (!response.ok) throw new Error('Network response was not ok');
                
                const repos = await response.json();
                
                if(repos.length === 0) {
                    container.innerHTML = '<p class="text-secondary">No public repositories found.</p>';
                    return;
                }

                container.innerHTML = ''; // Clear loader
                
                repos.forEach((repo, index) => {
                    const card = document.createElement('a');
                    card.href = repo.html_url;
                    card.target = '_blank';
                    card.className = 'github-card glass-card reveal-up';
                    card.style.transitionDelay = `${index * 0.1}s`;
                    
                    const lang = repo.language ? repo.language : 'Docs/Other';
                    const stars = repo.stargazers_count;
                    
                    card.innerHTML = `
                        <h4><i class="fab fa-github"></i> ${repo.name}</h4>
                        <p>${repo.description || 'No description provided.'}</p>
                        <div class="github-stats">
                            <span><i class="fas fa-circle" style="color: var(--accent-secondary); font-size: 0.6rem;"></i> ${lang}</span>
                            <span><i class="fas fa-star"></i> ${stars}</span>
                        </div>
                    `;
                    container.appendChild(card);
                    
                    // Trigger animation for dynamically added cards
                    setTimeout(() => {
                        card.classList.add('active');
                    }, 100);
                });
            } catch (error) {
                console.error('Error fetching GitHub data:', error);
                container.innerHTML = `
                    <div style="grid-column: 1 / -1; text-align: center; padding: 2rem; border: 1px dashed var(--glass-border); border-radius: 8px;">
                        <p class="text-secondary" style="margin-bottom: 1.5rem;">Unable to fetch GitHub repositories dynamically.</p>
                        <a href="https://github.com/${username}" target="_blank" class="btn btn-secondary">View Profile on GitHub</a>
                    </div>
                `;
            }
        };

        fetchGitHubData();
    }
});
