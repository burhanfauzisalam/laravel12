<?php

namespace App\Http\Controllers;

use App\Models\Document;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\View\View;

class DocumentController extends Controller
{
    public function index(): View
    {
        $documents = Document::latest()->paginate(10);

        return view('documents.index', compact('documents'));
    }

    public function create(): View
    {
        return view('documents.create');
    }

    public function store(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'title' => ['required', 'string', 'max:255'],
            'description' => ['nullable', 'string'],
            'file' => ['required', 'file', 'max:5120'],
        ]);

        $path = $request->file('file')->store('documents', 'public');

        Document::create([
            'title' => $validated['title'],
            'description' => $validated['description'] ?? null,
            'file_path' => $path,
        ]);

        return redirect()
            ->route('documents.index')
            ->with('status', 'Document created successfully.');
    }

    public function show(Document $document): View
    {
        return view('documents.show', compact('document'));
    }

    public function edit(Document $document): View
    {
        return view('documents.edit', compact('document'));
    }

    public function update(Request $request, Document $document): RedirectResponse
    {
        $validated = $request->validate([
            'title' => ['required', 'string', 'max:255'],
            'description' => ['nullable', 'string'],
            'file' => ['nullable', 'file', 'max:5120'],
        ]);

        $data = [
            'title' => $validated['title'],
            'description' => $validated['description'] ?? null,
        ];

        if ($request->hasFile('file')) {
            if ($document->file_path && Storage::disk('public')->exists($document->file_path)) {
                Storage::disk('public')->delete($document->file_path);
            }

            $data['file_path'] = $request->file('file')->store('documents', 'public');
        }

        $document->update($data);

        return redirect()
            ->route('documents.index')
            ->with('status', 'Document updated successfully.');
    }

    public function destroy(Document $document): RedirectResponse
    {
        if ($document->file_path && Storage::disk('public')->exists($document->file_path)) {
            Storage::disk('public')->delete($document->file_path);
        }

        $document->delete();

        return redirect()
            ->route('documents.index')
            ->with('status', 'Document deleted successfully.');
    }
}

