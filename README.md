# README

Backend in  Ruby on Rails per l'invio automatico di messaggi su Telegram agli "iscritti" (che possono essere privati, canali in cui il bot è admin o gruppi) del bar di Wikipedia in Italiano.
## Configurazione
L'installazione è la solita delle applicazioni Ruby on Rails. In questo caso il database usato (e consigliato) è PostgreSQL. Va attivato anche Sidekiq con Redis.

Vanno impostate le seguenti variabili d'ambiente:

* TOKEN (il token del bot Telegram creato con @BotFather)
* FALLBACK (l'ID di un utente Telegram, ottenibile tramite un bot come @userinfobot, a cui inviare informazioni su eventuali errori).
* BOT_USERNAME (l'username del bot, senza la chiocciola davanti, es. @Wikinotiziebot)
## Comandi
* start - Iscriviti agli aggiornamenti, in un gruppo, in un canale o nella tua chat privata
* stop - Smetti di ricevere gli aggionamenti
## Contributi
Ogni contributo è ben accetto, così come segnalazioni di problemi o richieste di miglioramenti.