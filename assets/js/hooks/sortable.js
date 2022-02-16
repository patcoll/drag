import Sortable from "sortablejs";

export default {
  mounted() {
    let handle = null;

    if (this.el.getAttribute("data-sortable-drag-handle")) {
      handle = this.el.getAttribute("data-sortable-drag-handle");
    }

    this.sortable = Sortable.create(this.el, {
      ghostClass: "opacity-30",
      handle,
      onEnd: () => {
        const items = Array.prototype.slice
          .call(document.querySelectorAll("[data-sortable-list-id]"))
          .map((el) => ({ el, list: el.closest('[phx-hook="Sortable"]') }))
          .map(
            ({
              el: {
                dataset: { sortableListId: id },
              },
            }) => id
          );

        const event = "did_sort";
        const params = { items };

        this.pushEvent(event, params);
      },
    });
  }
};
