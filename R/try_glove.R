## embedding through training

create_embedding_matrix <- function(text,
                                    word_vectors_size = 50,
                                    term_count_min = 1L,
                                    skip_grams_window = 5L) {
  text <- tolower(text)
  tokens <- text2vec::space_tokenizer(text)
  it <- text2vec::itoken(tokens, progressbar = FALSE)
  vocab <- text2vec::create_vocabulary(it)
  vocab <- text2vec::prune_vocabulary(vocab, term_count_min)
  vectorizer <- text2vec::vocab_vectorizer(vocab)
  tcm <- text2vec::create_tcm(it, vectorizer, skip_grams_window)
  glove <- text2vec::GlobalVectors$new(word_vectors_size, vocabulary = vocab, x_max = 10)
  wv_main <- glove$fit_transform(tcm, n_iter = 10, convergence_tol = 0.01)
  wv_context <- glove$components
  word_vectors <- wv_main + t(wv_context)
  return(word_vectors)
}

## embedding through pretrained vectors

download_vector_file <- function(type = "twitter") {
  if(type == "twitter") {
    vector_file = "~/glove.twitter.27B"
    if (!file.exists(vector_file)) {
      download.file("http://nlp.stanford.edu/data/glove.twitter.27B.zip", "~/glove.twitter.27B.zip")
      unzip ("~/glove.twitter.27B.zip", files = "glove.twitter.27B", exdir = "~/")
    }
  }
}



create_embedding_matrix2 <- function(text,
                                     vector_type = "twitter"
                                     vector_file = NULL) {
  text <- tolower(text)
  tokens <- text2vec::space_tokenizer(text)
  it <- text2vec::itoken(tokens, progressbar = FALSE)
  vocab <- text2vec::create_vocabulary(it)
  word_index <- data.frame(word = vocab[, 1])
  word_index$idx <- seq.int(nrow(word_index))
  ## read pretrained vectors
  if(!is.null(vector_file)) {
    if(vector_type == "twitter") {
      vector_file <- "glove.6B/glove.6B.50d.txt"
      lines <- readLines(file.path(vector_file))
      lines_split <- strsplit(lines, split = " ")
    }
  } else {
    lines <- readLines(file.path(vector_file))
    lines_split <- strsplit(lines, split = " ")
  }

  ## create vector matrix
  word_vectors <- matrix(data = lines_split)
  word_vectors <- do.call("rbind", word_vectors)
  word_list <- word_vectors[, 1]
  word_vectors <- word_vectors[, 2:ncol(word_vectors)]
  rownames(word_vectors) <- word_list
  ## select words vectors from vector matrix
  embedding_matrix <- matrix(0L, nrow = nrow(word_index), ncol = ncol(word_vectors))
  matchs <- match(word_index$word, rownames(word_vectors))
  i <- 0
  for (idx in matchs) {
    i <- i+1
    if(!is.na(idx)) {
      embedding_matrix[i, ] <- word_vectors[idx, ]
    }
  }
  return(embedding_matrix)
}
