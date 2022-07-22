function recall(test, groundtruth)
    relevantAndRetrieved = 0.0
    for i in test
        if (i in groundtruth)
            relevantAndRetrieved += 1.0
        end
    end
    relevantAndRetrieved / size(groundtruth)[1]
end