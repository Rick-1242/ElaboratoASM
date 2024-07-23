[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]
[![LinkedIn][linkedin-shield]][linkedin-url]


<h3 align="center">ELABORATO ASM</h3>

  <p align="center">
    software per la pianificazione delle attività di un sistema
produttivo
    <br />
</div>

## About The Project

Questo programma è progettato per eseguire un'analisi dei dati completa e creare visualizzazioni. Prende in input dati grezzi, li elabora per estrarre informazioni significative e genera vari tipi di rappresentazioni visive per facilitare l'interpretazione dei dati. Il programma è scritto in Python e utilizza librerie popolari come Pandas, NumPy, Matplotlib e Seaborn.
<p align="right">(<a href="#readme-top">back to top</a>)</p>


## Usage

Use this space to show useful examples of how a project can be used. Additional screenshots, code examples and demos work well in this space. You may also link to more resources.

_For more examples, please refer to the [Documentation](https://example.com)_

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- ROADMAP -->
# main

## _start
- controlla la validità degli argomenti se non ci sono salta all'etichetta _noArgsExit
- salta all'etichetta _openFile

## main menu
- utilizza la funzione MyPrint per stampare in stout il menù
- legge da stdin l'imput dell'utente
    - a seconda dell' imput dell'utente salta a
        - _HPF
        - _EDF
        - _exit

## _HPF
- stampa con myPrint mshHPF
- chiama la funzione HPF
- salta a _mainMENU

## _EDF
- stampa con myPrint mshEDF
- chiama la funzione EDF
- salta a _mainMENU

## no args exit
- chiama la funzione mySTDERR per stampare il messaggio noArgsExitmsg
- salta a _exit

## exit
- fa una sys call per dare l'errore



See the [open issues](https://github.com/Rick-1242/ElaboratoASM/issues) for a full list of proposed features (and known issues).

<p align="right">(<a href="#readme-top">back to top</a>)</p>


<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE.txt` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>
