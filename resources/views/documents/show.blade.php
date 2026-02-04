<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>View document</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@picocss/pico@2/css/pico.min.css">
</head>
<body>
<main class="container">
    <h1>{{ $document->title }}</h1>

    @if ($document->description)
        <p>{{ $document->description }}</p>
    @endif

    @php
        $url = Storage::disk('public')->url($document->file_path);
    @endphp

    <p>
        <a href="{{ $url }}" target="_blank">Open file in new tab</a>
    </p>

    <iframe src="{{ $url }}" style="width: 100%; height: 600px; border: 1px solid #ccc;"></iframe>

    <p>
        <a href="{{ route('documents.index') }}">Back to list</a>
    </p>
</main>
</body>
</html>

