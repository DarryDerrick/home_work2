import Time "mo:base/Time";
import Result "mo:base/Result";
import Buffer "mo:base/Buffer";

type Homework = {
    title: Text;
    description: Text;
    dueDate: Time.Time;
    completed: Bool;
};

var homeworkDiary = Buffer.Buffer<Homework>(0);

addHomework: shared (homework: Homework) -> async Nat {
    let id = homeworkDiary.size();
    homeworkDiary.add(homework);
    return id;
};

// Get a specific homework task by id
getHomework: shared query (id: Nat) -> async Result.Result<Homework, Text> {
    if (id >= homeworkDiary.size()) {
        return #err("Invalid homework id");
    } else {
        return #ok(homeworkDiary.get(id));
    };
};

// Update a homework task's title, description, and/or due date
updateHomework: shared (id: Nat, homework: Homework) -> async Result.Result<(), Text> {
    if (id >= homeworkDiary.size()) {
        return #err("Invalid homework id");
    };
    homeworkDiary.put(id, homework);
    return #ok();
};

// Mark a homework task as completed
markAsCompleted: shared (id: Nat) -> async Result.Result<(), Text> {
    if (id >= homeworkDiary.size()) {
        return #err("Invalid homework id");
    };
    let homework = homeworkDiary.get(id);
    homeworkDiary.put(id, {
        title = homework.title;
        description = homework.description;
        dueDate = homework.dueDate;
        completed = true
    });
    return #ok(());
};


// Delete a homework task by id
deleteHomework: shared (id: Nat) -> async Result.Result<(), Text> {
    if (id >= homeworkDiary.size()) {
        return #err("Invalid homework id");
    };
    ignore homeworkDiary.remove(id);
    return #ok();
};

// Get the list of all homework tasks
getAllHomework: shared query () -> async [Homework] {
    return Buffer.toArray(homeworkDiary);
};

// Get the list of pending (not completed) homework tasks
getPendingHomework: shared query () -> async [Homework] {
    return Buffer.toArray(Buffer.filter(homeworkDiary, func(h : Homework) : Bool { not h.completed }));
};

// Search for homework tasks based on a search term
searchHomework: shared query (searchTerm: Text) -> async [Homework] {
    let pattern = #text(searchTerm);
    return Buffer.toArray(Buffer.filter(homeworkDiary, func(h : Homework) : Bool {
        Text.contains(h.title, pattern) or Text.contains(h.description, pattern)
    }));
};

