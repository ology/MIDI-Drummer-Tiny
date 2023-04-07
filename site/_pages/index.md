<div class="text-center my-5 py-5 mx-auto w-lg-50">
  <p class="lead">MIDI::Drummer::Tiny is a Perl module that implements MIDI drum methods.</p>
  <p class="lead">Put some MIDI drums in your next perl composition!</p>
  <p class="pt-5">
    <img alt="GitHub Issues" src="https://img.shields.io/github/issues/ology/MIDI-Drummer-Tiny" title="GitHub Issues">
  </p>
</div>

----

<div class="text-center">
  <h2 class="display-1">Definitions</h2>
  <h3>What is MIDI?</h3>
  <p>MIDI stands for "Musical Instrument Digital Interface."</p>
  <p>MIDI is a protocol that allows electronic musical instruments and computers to exchange musical data with each other.</p>
  <h3>What are drums?</h3>
  <p>Drums are percussion instruments that produce sound by being struck, shaken, or rubbed.</p>
  <p>Drums provide the rhythmic foundation of a song and can also add dynamic energy and intensity to a performance.</p>
</div>

----

<div class="text-center">
  <h2 class="display-1">Features of the Module</h2>
  <h3>Configuration settings</h3>
  <p>Filename, Beats per minute, Volume, Time signature, Reverb, etc.</p>
  <h3>The kit itself</h3>
  <p>Open, Closed, and Pedal hihats, Acoustic and Electric snares, Acoustic and Electric bass drums, etc.</p>
  <h3>Drum methods</h3>
  <p>Rolls, Flam, Metronomes in different meters, Bitstring patterns, Fills, etc.</p>
</div>

----

<h2 class="display-1 text-center pb-3">Quick Examples</h2>

<div class="row">
  <div class="col-lg-6">
    <h3>Alternate kick and snare in 4/4</h3>
    <pre><code>use MIDI::Drummer::Tiny ();

my $d = MIDI::Drummer::Tiny->new;

$d->note($d->quarter, $d->open_hh, $_ % 2 ? $d->kick : $d->snare)
    for 1 .. $d->beats * $d->bars;

$d->write;</code></pre>
  </div>

  <div class="col-lg-6">
    <h3>Same thing but with beat-strings</h3>
    <pre><code>use MIDI::Drummer::Tiny ();

my $d = MIDI::Drummer::Tiny->new;

$d->sync_patterns(
    $d->open_hh => [ '1111' ],
    $d->snare   => [ '0101' ],
    $d->kick    => [ '1010' ],
) for 1 .. $d->bars;

$d->write;</code></pre>
  </div>

</div>

----

<div class="row">
  <div class="col-12 col-lg-6">
    <h2 class="display-1">Download</h2>
    <p><a class="btn btn-primary btn-lg" href="https://metacpan.org/dist/MIDI-Drummer-Tiny"><i class="fa-solid fa-download"></i> Download from the CPAN</a></p>
  </div>
  <div class="col-12 col-lg-6">
    <h3>MIDI-Drummer-Tiny is available for Mac, Windows, Linux, and BSD distributions through the CPAN.</h3>
  </div>
</div>

----

<div class="text-center w-lg-75 w-xl-50 mx-auto">
  <p style="font-size:2rem">Powered by <a class="text-decoration:none" href="http://www.perl.org/">Perl</a></p>
  <h2 class="h4">What is Perl?</h2>
  <p>Perl is a high-level, general-purpose, interpreted, dynamic programming language and was developed by Larry Wall in 1987 as a Unix scripting language to make report processing easier. Since then, Perl has undergone many changes, revisions and is still in active development!</p>
</div>

