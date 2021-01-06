AbstractStore <- R6::R6Class("AbstractStore",
  public = list(
    list_experiments = function(self, view_type = c("active_only", "delete_only", "all")) {
      stop("Not implemented")
    },
    create_experiment = function(name, artifact_location) {
      stop("Not implemented")
    },
    get_experiment = function(experiment_id) {
      stop("Not implemented")
    },
    get_experiment_by_name = function(experiment_name) {
      for (experiment in self$list_experiments(view_type = "all")) {
        if (identical(experiment$name, experiment_name)) {
          return(experiment)
        }
      }
      return(NULL)
    },
    delete_experiment = function(experiment_id) {
      stop("Not implemented")
    },
    restore_experiment = function(experiment_id) {
      stop("Not implemented")
    },
    rename_experiment = function(experiment_id, new_name) {
      stop("Not implemented")
    },
    get_run = function(run_id) {
      stop("Not implemented")
    },
    update_run_info = function(run_id, run_status, end_time) {
      stop("Not implemented")
    },
    create_run = function(experiment_id, user_id, start_time, tags) {
      stop("Not implemented")
    },
    delete_run = function(run_id) {
      stop("Not implemented")
    },
    restore_run = function(run_id) {
      stop("Not implemented")
    },
    log_metric = function(run_id, metric) {
      self$log_batch(
        run_id,
        metrics = list(metric),
        params = list(),
        tags = list()
      )
    },
    log_param = function(run_id, param) {
      self$log_batch(
        run_id,
        metrics = list(),
        params = list(),
        tags = list()
      )
    },
    set_experiment_tag = function(experiment_id, tag):
        """
        Set a tag for the specified experiment

        :param experiment_id: String id for the experiment
        :param tag: :py:class:`mlflow.entities.ExperimentTag` instance to set
        """
        pass

    def set_tag(self, run_id, tag):
        """
        Set a tag for the specified run

        :param run_id: String id for the run
        :param tag: :py:class:`mlflow.entities.RunTag` instance to set
        """
        self.log_batch(run_id, metrics=[], params=[], tags=[tag])

    @abstractmethod
    def get_metric_history(self, run_id, metric_key):
        """
        Return a list of metric objects corresponding to all values logged for a given metric.

        :param run_id: Unique identifier for run
        :param metric_key: Metric name within the run

        :return: A list of :py:class:`mlflow.entities.Metric` entities if logged, else empty list
        """
        pass

    def search_runs(
        self,
        experiment_ids,
        filter_string,
        run_view_type,
        max_results=SEARCH_MAX_RESULTS_DEFAULT,
        order_by=None,
        page_token=None,
    ):
        """
        Return runs that match the given list of search expressions within the experiments.

        :param experiment_ids: List of experiment ids to scope the search
        :param filter_string: A search filter string.
        :param run_view_type: ACTIVE_ONLY, DELETED_ONLY, or ALL runs
        :param max_results: Maximum number of runs desired.
        :param order_by: List of order_by clauses.
        :param page_token: Token specifying the next page of results. It should be obtained from
            a ``search_runs`` call.

        :return: A list of :py:class:`mlflow.entities.Run` objects that satisfy the search
            expressions. The pagination token for the next page can be obtained via the ``token``
            attribute of the object; however, some store implementations may not support pagination
            and thus the returned token would not be meaningful in such cases.
        """
        runs, token = self._search_runs(
            experiment_ids, filter_string, run_view_type, max_results, order_by, page_token
        )
        return PagedList(runs, token)

    @abstractmethod
    def _search_runs(
        self, experiment_ids, filter_string, run_view_type, max_results, order_by, page_token
    ):
        """
        Return runs that match the given list of search expressions within the experiments, as
        well as a pagination token (indicating where the next page should start). Subclasses of
        ``AbstractStore`` should implement this method to support pagination instead of
        ``search_runs``.

        See ``search_runs`` for parameter descriptions.

        :return: A tuple of ``runs`` and ``token`` where ``runs`` is a list of
            :py:class:`mlflow.entities.Run` objects that satisfy the search expressions,
            and ``token`` is the pagination token for the next page of results.
        """
        pass

    def list_run_infos(
        self,
        experiment_id,
        run_view_type,
        max_results=SEARCH_MAX_RESULTS_DEFAULT,
        order_by=None,
        page_token=None,
    ):
        """
        Return run information for runs which belong to the experiment_id.

        :param experiment_id: The experiment id which to search
        :param run_view_type: ACTIVE_ONLY, DELETED_ONLY, or ALL runs
        :param max_results: Maximum number of results desired.
        :param order_by: List of order_by clauses.
        :param page_token: Token specifying the next page of results. It should be obtained from
            a ``list_run_infos`` call.

        :return: A list of :py:class:`mlflow.entities.RunInfo` objects that satisfy the
            search expressions. The pagination token for the next page can be obtained via the
            ``token`` attribute of the object; however, some store implementations may not support
            pagination and thus the returned token would not be meaningful in such cases.
        """
        search_result = self.search_runs(
            [experiment_id], None, run_view_type, max_results, order_by, page_token
        )
        return PagedList([run.info for run in search_result], search_result.token)

    @abstractmethod
    def log_batch(self, run_id, metrics, params, tags):
        """
        Log multiple metrics, params, and tags for the specified run

        :param run_id: String id for the run
        :param metrics: List of :py:class:`mlflow.entities.Metric` instances to log
        :param params: List of :py:class:`mlflow.entities.Param` instances to log
        :param tags: List of :py:class:`mlflow.entities.RunTag` instances to log

        :return: None.
        """
        pass

    @experimental
    @abstractmethod
    def record_logged_model(self, run_id, mlflow_model):
        """
        Record logged model information with tracking store. The list of logged model infos is
        maintained in a mlflow.models tag in JSON format.

        Note: The actual models are logged as artifacts via artifact repository.

        :param run_id: String id for the run
        :param mlflow_model: Model object to be recorded.

        NB: This API is experimental and may change in the future. The default implementation is a
        no-op.

        :return: None.
        """
        pass
