let currentSlide = 0;
const slides = document.querySelectorAll('.slide');
const progress = document.getElementById('progress');

function showSlide(index) {
    if (index >= slides.length) currentSlide = slides.length - 1;
    if (index < 0) currentSlide = 0;
    
    // Atualiza classes ativas
    slides.forEach((slide, i) => {
        if (i === currentSlide) {
            slide.classList.add('active');
        } else {
            slide.classList.remove('active');
        }
    });

    // Atualiza barra de progresso no rodape
    const percentage = ((currentSlide + 1) / slides.length) * 100;
    progress.style.width = percentage + '%';
}

function nextSlide() {
    if(currentSlide < slides.length - 1){
        currentSlide++;
        showSlide(currentSlide);
    }
}

function prevSlide() {
    if(currentSlide > 0){
        currentSlide--;
        showSlide(currentSlide);
    }
}

// Ouvinte do Teclado para passar via setas igual Powerpoint
document.addEventListener('keydown', (e) => {
    if (e.key === 'ArrowRight' || e.key === 'Space') {
        nextSlide();
    } else if (e.key === 'ArrowLeft') {
        prevSlide();
    }
});

// Init
showSlide(currentSlide);
