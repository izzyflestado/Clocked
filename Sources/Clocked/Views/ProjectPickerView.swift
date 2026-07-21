import SwiftUI
import SwiftData

// MARK: - ProjectPickerView

struct ProjectPickerView: View {
    @Environment(\.modelContext) private var context
    @Binding var selectedProject: Project?
    let projects: [Project]

    private enum Mode: Equatable {
        case collapsed
        case list
        case newProject
        case rename(Project)
        case confirmDelete(Project)
    }

    @State private var mode: Mode = .collapsed
    @State private var nameField: String = ""

    var body: some View {
        HStack {
            Spacer()
            selectorBox
            Spacer()
        }
        .onAppear {
            if selectedProject == nil {
                selectedProject = projects.first
            }
        }
    }

    private var selectorBox: some View {
        VStack(alignment: .leading, spacing: 8) {
            header

            switch mode {
            case .collapsed:
                EmptyView()
            case .list:
                Divider()
                listContent
            case .newProject:
                Divider()
                namingContent(title: "New Project", confirmTitle: "Create", onConfirm: createProject)
            case .rename(let project):
                Divider()
                namingContent(title: "Rename Project", confirmTitle: "Save") {
                    rename(project)
                }
            case .confirmDelete(let project):
                Divider()
                deleteContent(project)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .frame(width: 183)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.15))
        )
    }

    // MARK: Header row

    private var header: some View {
        Button {
            mode = (mode == .collapsed) ? .list : .collapsed
        } label: {
            ZStack {
                Text(selectedProject?.name ?? "Select Project")
                    .font(.system(size: 15, weight: .medium))
                                    .frame(maxWidth: .infinity, alignment: .center)


                HStack {
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: List content

    private var listContent: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(projects, id: \.persistentModelID) { project in
                HStack(spacing: 8) {
                    Button {
                        selectedProject = project
                        mode = .collapsed
                    } label: {
                        HStack {
                            Image(systemName: "checkmark")
                                .opacity(project == selectedProject ? 1 : 0)
                            Text(project.name)
                            Spacer()
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    Button {
                        nameField = project.name
                        mode = .rename(project)
                    } label: {
                        Image(systemName: "pencil")
                    }
                    .buttonStyle(.plain)

                    Button {
                        mode = .confirmDelete(project)
                    } label: {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(.plain)
                    .disabled(TimerManager.shared.isActive(project))
                    .opacity(TimerManager.shared.isActive(project) ? 0.3 : 1)
                }
                .font(.callout)
            }

            if !projects.isEmpty {
                Divider()
            }

            Button {
                nameField = ""
                mode = .newProject
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                    Text("New Project…")
                    Spacer()
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .foregroundColor(.accentColor)
        }
    }

    // MARK: Naming content

    private func namingContent(title: String, confirmTitle: String, onConfirm: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            TextField("Project name", text: $nameField)
                .textFieldStyle(.roundedBorder)
                .onSubmit(onConfirm)

            HStack {
                Button("Cancel") { mode = .collapsed }
                Spacer()
                Button(confirmTitle, action: onConfirm)
                    .disabled(nameField.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }

    // MARK: Delete confirmation content
    private func deleteContent(_ project: Project) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Delete “\(project.name)”? This also deletes its history.")
                .font(.caption)
                .foregroundColor(.secondary)

            HStack {
                Button("Cancel") { mode = .collapsed }
                Spacer()
                Button("Delete", role: .destructive) { delete(project) }
            }
        }
    }

    // MARK: Actions

    private func createProject() {
        let trimmed = nameField.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let project = Project(name: trimmed)
        context.insert(project)
        try? context.save()
        selectedProject = project
        mode = .collapsed
    }

    private func rename(_ project: Project) {
        let trimmed = nameField.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        project.name = trimmed
        try? context.save()
        mode = .collapsed
    }

    private func delete(_ project: Project) {
        guard !TimerManager.shared.isActive(project) else {
            mode = .collapsed
            return
        }
        if selectedProject == project {
            selectedProject = nil
        }
        context.delete(project)
        try? context.save()
        mode = .collapsed
    }
}
