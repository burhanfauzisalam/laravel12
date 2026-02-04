<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Upload document</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@picocss/pico@2/css/pico.min.css">
</head>
<body>
<main class="container">
    <h1>Upload document</h1>

    @if ($errors->any())
        <article>
            <ul>
                @foreach ($errors->all() as $error)
                    <li>{{ $error }}</li>
                @endforeach
            </ul>
        </article>
    @endif

    <form action="{{ route('documents.store') }}" method="POST" enctype="multipart/form-data">
        @csrf

        <label>
            Title
            <input type="text" name="title" value="{{ old('title') }}" required>
        </label>

        <label>
            Description
            <textarea name="description" rows="4">{{ old('description') }}</textarea>
        </label>

        <label>
            File
            <input type="file" name="file" required>
        </label>

        <button type="submit">Save</button>
        <a href="{{ route('documents.index') }}">Cancel</a>
    </form>
</main>
</body>
</html>

