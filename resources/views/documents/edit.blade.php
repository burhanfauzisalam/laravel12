<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Edit document</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@picocss/pico@2/css/pico.min.css">
</head>
<body>
<main class="container">
    <h1>Edit document</h1>

    @if ($errors->any())
        <article>
            <ul>
                @foreach ($errors->all() as $error)
                    <li>{{ $error }}</li>
                @endforeach
            </ul>
        </article>
    @endif

    <form action="{{ route('documents.update', $document) }}" method="POST" enctype="multipart/form-data">
        @csrf
        @method('PUT')

        <label>
            Title
            <input type="text" name="title" value="{{ old('title', $document->title) }}" required>
        </label>

        <label>
            Description
            <textarea name="description" rows="4">{{ old('description', $document->description) }}</textarea>
        </label>

        <p>Current file:
            @if ($document->file_path)
                <a href="{{ Storage::disk('public')->url($document->file_path) }}" target="_blank">View file</a>
            @else
                <em>No file</em>
            @endif
        </p>

        <label>
            Replace file (optional)
            <input type="file" name="file">
        </label>

        <button type="submit">Update</button>
        <a href="{{ route('documents.index') }}">Cancel</a>
    </form>
</main>
</body>
</html>

