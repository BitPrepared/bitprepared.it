
/* Al caricamento della pagina... */

$(document).ready(function() {

	/* 
	 * Facendo scroll della pagina il logo scompare e rimane solo il menu.
	 * Il link "Home" viene sostituito da "BitPrepared", che nell'html ha class ".show_title".
	 * Al caricamento della pagina nascondo "BitPrepared" e visualizzo soltanto "Home" */
	$(".show_title").hide();

	/* Se la larghezza della pagina è > di 992px mostro il menu in tutta la sua larghezza e
	 * nascondo .menu-icon, ovvero l'icona del menu per mobile; */
	if ($(window).width() >= 992) {
		$('.menu-icon').hide();
		$('.button-icon').hide();
	}
});

/* Allo scroll della pagina nascondo il logo e la sua didascalia (figure) */
$(window).scroll(function() {

	if ($(this).scrollTop() > 1){  
		$('figure').hide();
		$("nav").css("top", "0");
		$(".show_title").show();
		$(".hide_title").hide();
  	} else {
	
		var figure_height = $('figure').height();

		$('figure').show();
		$("nav").css("top", figure_height);
		$(".show_title").hide();
		$(".hide_title").show();
	}
});

/* Al ridimensionamento della pagina, se la larghezza < 992px (e quindi dimensione presumibilmente da mobile)
 * mostro l'icona per il menu e nascondo i link. */
$( window ).resize(function() {
	if ($(window).width() < 992) {
		$('.menu-icon').show(); 
		
		/* Al click sull'icona del menu mostro e nascondo tutti i link */
		$( ".menu-icon" ).unbind('click').click(function() {
			$( "#menu" ).slideToggle("slow");
		});
	}
	else {
		$('.menu-icon').hide();
		$('.button-icon').hide();
		
	        $('#menu').show();	
	}
});
