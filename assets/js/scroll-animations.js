/**
 * Scout Tech Modern - Scroll Animations
 * Vanilla JavaScript with IntersectionObserver
 * Zero dependencies, lightweight and performant
 */

(function() {
	'use strict';

		// ===== MOBILE MENU TOGGLE =====
		const navbarToggle = document.getElementById('navbar-toggle');
		const navbarNav = document.getElementById('navbar-nav');

		if (navbarToggle && navbarNav) {
			navbarToggle.addEventListener('click', () => {
				const isExpanded = navbarToggle.classList.toggle('active');
				navbarNav.classList.toggle('active');

				// Update aria-expanded for accessibility
				navbarToggle.setAttribute('aria-expanded', isExpanded);

				// Focus management: move focus to first link when opening, back to toggle when closing
				if (isExpanded) {
					// Menu opened - focus first link
					const firstLink = navbarNav.querySelector('a');
					if (firstLink) {
						setTimeout(() => firstLink.focus(), 100);
					}
				} else {
					// Menu closed - focus returns to toggle
					navbarToggle.focus();
				}
			});

			// Close menu when clicking a link
			const navLinks = navbarNav.querySelectorAll('a');
			navLinks.forEach(link => {
				link.addEventListener('click', () => {
					navbarToggle.classList.remove('active');
					navbarNav.classList.remove('active');
					navbarToggle.setAttribute('aria-expanded', 'false');
				});
			});

			// Close menu when clicking outside
			document.addEventListener('click', (e) => {
				if (!navbarToggle.contains(e.target) && !navbarNav.contains(e.target)) {
					const wasOpen = navbarToggle.classList.contains('active');
					navbarToggle.classList.remove('active');
					navbarNav.classList.remove('active');
					navbarToggle.setAttribute('aria-expanded', 'false');
				}
			});

			// Keyboard support: ESC to close menu
			navbarToggle.addEventListener('keydown', (e) => {
				if (e.key === 'Escape' && navbarToggle.classList.contains('active')) {
					navbarToggle.classList.remove('active');
					navbarNav.classList.remove('active');
					navbarToggle.setAttribute('aria-expanded', 'false');
					navbarToggle.focus();
				}
			});

			// Trap focus within menu when open (mobile only)
			navbarNav.addEventListener('keydown', (e) => {
				if (e.key === 'Escape') {
					navbarToggle.classList.remove('active');
					navbarNav.classList.remove('active');
					navbarToggle.setAttribute('aria-expanded', 'false');
					navbarToggle.focus();
				}
			});
		}
	// ===== INTERSECTION OBSERVER FOR SCROLL REVEAL =====
	const observerOptions = {
		root: null, // viewport
		rootMargin: '0px',
		threshold: 0.1 // trigger when 10% visible
	};

	const observer = new IntersectionObserver((entries) => {
		entries.forEach(entry => {
			if (entry.isIntersecting) {
				entry.target.classList.add('active');
				// Optional: stop observing after reveal
				// observer.unobserve(entry.target);
			}
		});
	}, observerOptions);

	// Observe all elements with .reveal class
	const revealElements = document.querySelectorAll('.reveal');
	revealElements.forEach(el => observer.observe(el));

	// ===== SMOOTH SCROLL FOR ANCHOR LINKS =====
	document.querySelectorAll('a[href^="#"]').forEach(anchor => {
		anchor.addEventListener('click', function (e) {
			const href = this.getAttribute('href');
			if (href === '#') return;

			const target = document.querySelector(href);
			if (target) {
				e.preventDefault();
				target.scrollIntoView({
					behavior: 'smooth',
					block: 'start'
				});
			}
		});
	});

	// ===== PARALLAX EFFECT FOR HERO =====
	// DISABILITATO - Causa scatti durante lo scroll
	/*
	let ticking = false;
	window.addEventListener('scroll', () => {
		if (!ticking) {
			window.requestAnimationFrame(() => {
				const hero = document.querySelector('.hero');
				if (hero) {
					const scrolled = window.pageYOffset;
					const parallaxSpeed = 0.5;
					hero.style.backgroundPositionY = `${scrolled * parallaxSpeed}px`;
				}
				ticking = false;
			});
			ticking = true;
		}
	}, { passive: true });
	*/

	// ===== TYPING EFFECT CHECK =====
	// Note: The typing effect is now pure CSS in hero-subtitle
	// This function ensures it resets properly when element comes into view
	const heroSubtitle = document.querySelector('.hero-subtitle');
	if (heroSubtitle) {
		const subtitleObserver = new IntersectionObserver((entries) => {
			entries.forEach(entry => {
				if (entry.isIntersecting) {
					// Force animation restart
					entry.target.style.animation = 'none';
					entry.target.offsetHeight; // Trigger reflow
					entry.target.style.animation = 'typing 3.5s steps(40, end), blink-caret 0.75s step-end infinite';
				}
			});
		}, { threshold: 0.5 });

		subtitleObserver.observe(heroSubtitle);
	}

	// ===== PREFERS REDUCED MOTION =====
	// Respect user's motion preferences
	const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)');

	if (prefersReducedMotion.matches) {
		// Disable all animations
		document.documentElement.style.setProperty('--transition-fast', '0ms');
		document.documentElement.style.setProperty('--transition-base', '0ms');
		document.documentElement.style.setProperty('--transition-slow', '0ms');

		// Show all reveal elements immediately
		document.querySelectorAll('.reveal').forEach(el => {
			el.classList.add('active');
		});
	}

	// Listen for changes in preference
	prefersReducedMotion.addEventListener('change', () => {
		location.reload();
	});

	// ===== CONSOLE SIGNATURE =====
	console.log('%c Bit Prepared ', 'background: #1a7f1a; color: #fff; padding: 5px 10px; border-radius: 3px;');
	console.log('%c Digito ergo sum ', 'background: #00d9ff; color: #0a1f0a; padding: 5px 10px; border-radius: 3px;');
	console.log('https://www.bitprepared.it');

})();
