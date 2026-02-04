<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Documents</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@picocss/pico@2/css/pico.min.css">
</head>
<body>
<main class="container">
    <h1>Documents</h1>

    @if (session('status'))
        <article role="status">{{ session('status') }}</article>
    @endif

    <p>
        <a href="{{ route('documents.create') }}" role="button">Upload new document</a>
    </p>

    @if ($documents->isEmpty())
        <p>No documents yet.</p>
    @else
        <table role="grid">
            <thead>
            <tr>
                <th>Title</th>
                <th>Uploaded at</th>
                <th>Actions</th>
            </tr>
            </thead>
            <tbody>
            @foreach ($documents as $document)
                <tr>
                    <td>{{ $document->title }}</td>
                    <td>{{ $document->created_at->format('Y-m-d H:i') }}</td>
                    <td>
                        <a href="{{ route('documents.show', $document) }}">View</a>
                        <a href="{{ route('documents.edit', $document) }}">Edit</a>
                        <form action="{{ route('documents.destroy', $document) }}" method="POST" style="display:inline">
                            @csrf
                            @method('DELETE')
                            <button type="submit" onclick="return confirm('Delete this document?')">Delete</button>
                        </form>
                    </td>
                </tr>
            @endforeach
            </tbody>
        </table>

        {{ $documents->links() }}
    @endif

    <p><a href="{{ url('/') }}">Back to home</a></p>
</main>
</body>
</html>

